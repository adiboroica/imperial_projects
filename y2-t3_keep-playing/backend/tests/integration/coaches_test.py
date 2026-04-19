import pytest
from datetime import date, time, timedelta
from unittest.mock import patch

from django.utils import timezone
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient

from app.models import Event, Organiser, User


@pytest.mark.django_db
class CoachFeedTest:

    def test_feed_shows_unassigned_future_events(self, coach_client, sample_event):
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        names = [e['name'] for e in response.data]
        assert 'Football Training' in names

    def test_feed_excludes_assigned_events(self, coach_client, assigned_event):
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        names = [e['name'] for e in response.data]
        assert 'Swimming Lessons' not in names

    def test_feed_excludes_blocked_organiser(self, coach_client, coach_user, sample_event, organiser_user):
        organiser_user.organiser.blocked.add(coach_user)
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        assert len(response.data) == 0

    def test_feed_excludes_past_events(self, coach_client, organiser_user):
        now = timezone.now()
        Event.objects.create(
            name='Yesterday Match',
            sport='Football',
            role='Coach',
            date=date.today() - timedelta(days=1),
            location='Old Stadium',
            details='Details',
            price=50,
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
        names = [e['name'] for e in response.data]
        assert 'Yesterday Match' not in names


@pytest.mark.django_db
class CoachApplyTest:

    def test_apply_to_event(self, coach_client, coach_user, sample_event):
        response = coach_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert coach_user in sample_event.offers.all()

    def test_unapply_from_event(self, coach_client, coach_user, sample_event):
        sample_event.offers.add(coach_user)
        response = coach_client.patch(f'/coach/events/{sample_event.pk}/unapply/')
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert coach_user not in sample_event.offers.all()

    def test_cancel_assigned_job(self, coach_client, coach_user, assigned_event):
        response = coach_client.patch(f'/coach/events/{assigned_event.pk}/cancel/')
        assert response.status_code == 202
        assigned_event.refresh_from_db()
        assert assigned_event.coach_user is None
        assert assigned_event.coach is False

    def test_cancel_ignores_malicious_request_body(self, coach_client, coach_user, assigned_event):
        response = coach_client.patch(
            f'/coach/events/{assigned_event.pk}/cancel/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 202
        assigned_event.refresh_from_db()
        assert assigned_event.coach is False
        assert assigned_event.coach_user is None

    def test_cannot_apply_to_assigned_event(self, coach_client, assigned_event):
        response = coach_client.patch(f'/coach/events/{assigned_event.pk}/apply/')
        assert response.status_code == 400
        assert 'already has a coach' in response.data['error_msg']

    def test_cannot_apply_to_past_event(self, coach_client, organiser_user):
        now = timezone.now()
        past = Event.objects.create(
            name='Past Event',
            sport='Football',
            role='Coach',
            date=date.today() - timedelta(days=1),
            location='Old Stadium',
            details='Details',
            price=50,
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 0),
            flexible_end_time=time(13, 0),
            organiser_user=organiser_user,
            creation_started=now,
            creation_ended=now,
        )
        response = coach_client.patch(f'/coach/events/{past.pk}/apply/')
        assert response.status_code == 400
        assert 'past' in response.data['error_msg']

    def test_blocked_coach_cannot_apply(self, coach_client, coach_user, sample_event, organiser_user):
        organiser_user.organiser.blocked.add(coach_user)
        response = coach_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        assert response.status_code == 403
        assert 'blocked' in response.data['error_msg']


@pytest.mark.django_db
class CoachUpcomingJobsTest:

    def test_upcoming_jobs(self, coach_client, assigned_event):
        response = coach_client.get('/coach/upcoming-jobs/')
        assert response.status_code == 200
        assert len(response.data) == 1
        assert response.data[0]['name'] == 'Swimming Lessons'

    def test_upcoming_jobs_excludes_other_coaches(self, coach_client, sample_event):
        response = coach_client.get('/coach/upcoming-jobs/')
        assert response.status_code == 200
        assert len(response.data) == 0


@pytest.mark.django_db
class CoachProfileTest:

    def test_view_coach_profile(self, coach_client, organiser_user):
        response = coach_client.get(f'/coach/{organiser_user.pk}/')
        assert response.status_code == 200
        assert response.data['username'] == organiser_user.username

    def test_view_coach_profile_not_found(self, coach_client):
        response = coach_client.get('/coach/99999/')
        assert response.status_code == 404

    def test_organiser_can_view_coach_profile(self, organiser_client, coach_user):
        response = organiser_client.get(f'/coach/{coach_user.pk}/')
        assert response.status_code == 200
        assert response.data['username'] == coach_user.username

    def test_unauthenticated_cannot_view_profile(self, api_client, coach_user):
        response = api_client.get(f'/coach/{coach_user.pk}/')
        assert response.status_code == 401


@pytest.mark.django_db
class CoachPermissionsTest:

    def test_organiser_cannot_access_feed(self, organiser_client):
        response = organiser_client.get('/coach/feed/')
        assert response.status_code == 403

    def test_organiser_cannot_apply(self, organiser_client, sample_event):
        response = organiser_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        assert response.status_code == 403


@pytest.mark.django_db
class CoachCancelOwnershipTest:

    def test_coach_cannot_cancel_another_coachs_event(self, coach_user2, assigned_event):
        token = Token.objects.create(user=coach_user2)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.patch(f'/coach/events/{assigned_event.pk}/cancel/')
        assert response.status_code == 403
        assigned_event.refresh_from_db()
        assert assigned_event.coach_user is not None


@pytest.mark.django_db
class CoachApplyNotificationTest:

    @patch('app.services.coach.notify_organiser_new_offer')
    def test_apply_triggers_notification(self, mock_notify, coach_client, coach_user, sample_event):
        coach_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        mock_notify.assert_called_once_with(
            sample_event.organiser_user, coach_user, sample_event,
        )

    @patch('app.services.coach.notify_organiser_coach_cancelled')
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
