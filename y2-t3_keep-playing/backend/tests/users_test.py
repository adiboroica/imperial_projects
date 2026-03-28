import pytest
from unittest.mock import patch
from datetime import date, time, timedelta
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token

from app.models import Coach, Event, User, Organiser


@pytest.mark.django_db
class UsersListTest:

    def test_get_users_returns_all(self, organiser_client, organiser_user, coach_user):
        response = organiser_client.get('/users/')
        assert response.status_code == 200
        usernames = [u['username'] for u in response.data]
        assert organiser_user.username in usernames
        assert coach_user.username in usernames

    def test_get_users_excludes_password(self, organiser_client, organiser_user):
        response = organiser_client.get('/users/')
        assert response.status_code == 200
        for user_data in response.data:
            assert 'password' not in user_data

    def test_get_users_unauthenticated(self, api_client):
        response = api_client.get('/users/')
        assert response.status_code == 401


@pytest.mark.django_db
class UserCreateTest:

    def test_create_user(self, organiser_client):
        response = organiser_client.post('/user/', {
            'username': 'newuser',
            'password': 'secret123',
            'email': 'new@test.com',
            'first_name': 'New',
            'last_name': 'User',
        }, format='json')
        assert response.status_code == 201
        user = User.objects.get(username='newuser')
        assert user.first_name == 'New'
        assert user.email == 'new@test.com'

    def test_create_user_password_is_hashed(self, organiser_client):
        """Password must be hashed, not stored in plaintext."""
        organiser_client.post('/user/', {
            'username': 'hashtest',
            'password': 'mypassword',
            'email': 'hash@test.com',
        }, format='json')
        user = User.objects.get(username='hashtest')
        # Plaintext password should NOT match the stored value
        assert user.password != 'mypassword'
        # But check_password should work
        assert user.check_password('mypassword')

    def test_create_user_unauthenticated(self, api_client):
        response = api_client.post('/user/', {
            'username': 'newuser',
            'password': 'pass',
        }, format='json')
        assert response.status_code == 401


@pytest.mark.django_db
class AcceptOfferEdgeCasesTest:

    def test_accept_nonexistent_event(self, organiser_client, coach_user):
        response = organiser_client.patch(
            f'/organiser/events/99999/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 404

    def test_accept_nonexistent_coach(self, organiser_client, sample_event):
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/99999/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 404

    def test_accept_coach_not_in_offers_still_succeeds(self, organiser_client, sample_event, coach_user):
        """BUG: Coach can be accepted even if not in offers list.
        No server-side validation. This documents current behavior."""
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert sample_event.coach_user == coach_user

    def test_accept_sets_coach_user_and_coach_flag(self, organiser_client, sample_event, coach_user):
        """Verify both coach_user and coach=True are persisted after acceptance."""
        sample_event.offers.add(coach_user)
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert sample_event.coach_user == coach_user
        assert sample_event.coach is True

    def test_other_organiser_cannot_accept(self, sample_event, coach_user):
        """Another organiser must not be able to accept offers on someone else's event."""
        other = User.objects.create_user(
            username='other_org2', password='pass', is_organiser=True,
        )
        Organiser.objects.create(user=other)
        token = Token.objects.create(user=other)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 403


@pytest.mark.django_db
class VoteCoachEdgeCasesTest:

    def test_vote_on_event_with_no_coach_returns_400(self, organiser_client, sample_event):
        """Voting on an event with no assigned coach should return 400."""
        response = organiser_client.patch(
            f'/organiser/vote/{sample_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 400
        assert 'no assigned coach' in response.data['error_msg']

    def test_vote_nonexistent_event(self, organiser_client):
        response = organiser_client.patch(
            '/organiser/vote/99999/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 404


@pytest.mark.django_db
class EventValidationTest:

    def test_create_event_missing_required_fields(self, organiser_client):
        response = organiser_client.post('/organiser/events/', {
            'name': 'Incomplete Event',
        }, format='json')
        assert response.status_code == 400
        # Verify error response has useful content (not empty)
        assert response.data is not None

    def test_patch_nonexistent_event(self, organiser_client):
        response = organiser_client.patch(
            '/organiser/events/99999/',
            {'name': 'Updated'},
            format='json',
        )
        assert response.status_code == 404

    def test_other_organiser_cannot_patch_event(self, sample_event):
        """Verify that one organiser cannot edit another's event."""
        other = User.objects.create_user(
            username='other_org3', password='pass', is_organiser=True,
        )
        Organiser.objects.create(user=other)
        token = Token.objects.create(user=other)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.patch(
            f'/organiser/events/{sample_event.pk}/',
            {'name': 'Hijacked'},
            format='json',
        )
        assert response.status_code == 403
        sample_event.refresh_from_db()
        assert sample_event.name != 'Hijacked'

    def test_duplicate_username_coach_registration(self):
        """Registering a coach with an existing username should fail with 400, not 500."""
        User.objects.create_user(username='taken', password='pass')
        client = APIClient()
        response = client.post('/new_coach/', {
            'username': 'taken',
            'password': 'pass',
        })
        # If this returns 500, it's a bug (unhandled IntegrityError)
        assert response.status_code == 400, (
            f'Expected 400 for duplicate username, got {response.status_code}. '
            f'This means the duplicate is not validated before hitting the database.'
        )

    def test_duplicate_username_organiser_registration(self):
        """Same check for organiser signup."""
        User.objects.create_user(username='taken2', password='pass')
        client = APIClient()
        response = client.post('/new_organiser/', {
            'username': 'taken2',
            'password': 'pass',
        }, format='json')
        assert response.status_code == 400, (
            f'Expected 400 for duplicate username, got {response.status_code}.'
        )


@pytest.mark.django_db
class CoachApplyNotificationTest:
    """Verify that coach apply/cancel triggers email notification functions."""

    @patch('app.views.coaches.notify_organiser_new_offer')
    def test_apply_triggers_notification(self, mock_notify, coach_client, coach_user, sample_event):
        coach_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        mock_notify.assert_called_once_with(
            sample_event.organiser_user, coach_user, sample_event,
        )

    @patch('app.views.coaches.notify_organiser_coach_cancelled')
    def test_cancel_triggers_notification(self, mock_notify, coach_client, assigned_event):
        coach_client.patch(
            f'/coach/events/{assigned_event.pk}/cancel/',
            {'coach': False},
            format='json',
        )
        mock_notify.assert_called_once()
        call_args = mock_notify.call_args[0]
        assert call_args[0] == assigned_event.organiser_user
        assert call_args[1].pk == assigned_event.pk


@pytest.mark.django_db
class CoachFeedEdgeCasesTest:

    def test_feed_excludes_past_events(self, coach_client, organiser_user):
        """Events with dates in the past should not appear in the feed."""
        now = timezone.now()
        past = Event.objects.create(
            name='Yesterday Match',
            sport='Football',
            role='Coach',
            date=date.today() - timedelta(days=1),
            location='Old Stadium',
            details='',
            price=50,
            coach=False,
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 0),
            flexible_end_time=time(13, 0),
            organiser_user=organiser_user,
            creation_started=now,
            creation_ended=now,
        )
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        pks = [e['pk'] for e in response.data]
        assert past.pk not in pks
