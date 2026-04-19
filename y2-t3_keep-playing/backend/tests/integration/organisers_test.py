import pytest

from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient

from app.models import Coach, Organiser, User


@pytest.mark.django_db
class OrganiserProfileTest:

    def test_get_profile(self, organiser_client, organiser_user):
        response = organiser_client.get('/organiser/')
        assert response.status_code == 200
        assert response.data['user'] == organiser_user.pk

    def test_update_defaults(self, organiser_client, organiser_user):
        response = organiser_client.patch('/organiser/', {
            'default_sport': 'Tennis',
            'default_role': 'Coach',
            'default_price': 100,
            'default_location': 'Wimbledon',
            'favourites_ids': [],
            'blocked_ids': [],
        }, format='json')
        assert response.status_code == 202
        organiser_user.organiser.refresh_from_db()
        assert organiser_user.organiser.default_sport == 'Tennis'


@pytest.mark.django_db
class OrganiserFavouritesTest:

    def test_add_favourite(self, organiser_client, organiser_user, coach_user):
        response = organiser_client.patch(f'/organiser/add-favourite/{coach_user.pk}/')
        assert response.status_code == 202
        assert coach_user in organiser_user.organiser.favourites.all()

    def test_remove_favourite(self, organiser_client, organiser_user, coach_user):
        organiser_user.organiser.favourites.add(coach_user)
        response = organiser_client.patch(f'/organiser/remove-favourite/{coach_user.pk}/')
        assert response.status_code == 202
        assert coach_user not in organiser_user.organiser.favourites.all()


@pytest.mark.django_db
class OrganiserBlockTest:

    def test_block_coach(self, organiser_client, organiser_user, coach_user):
        response = organiser_client.patch(f'/organiser/block/{coach_user.pk}/')
        assert response.status_code == 202
        assert coach_user in organiser_user.organiser.blocked.all()

    def test_unblock_coach(self, organiser_client, organiser_user, coach_user):
        organiser_user.organiser.blocked.add(coach_user)
        response = organiser_client.patch(f'/organiser/unblock/{coach_user.pk}/')
        assert response.status_code == 202
        assert coach_user not in organiser_user.organiser.blocked.all()


@pytest.mark.django_db
class AcceptOfferTest:

    def test_accept_coach_offer(self, organiser_client, sample_event, coach_user):
        sample_event.offers.add(coach_user)
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert sample_event.coach_user == coach_user

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

    def test_accept_coach_not_in_offers_rejected(self, organiser_client, sample_event, coach_user):
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 400
        assert 'not applied' in response.data['error_msg']

    def test_accept_non_coach_user_rejected(self, organiser_client, sample_event, organiser_user):
        sample_event.offers.add(organiser_user)
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{organiser_user.pk}/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 400
        assert 'not a coach' in response.data['error_msg']

    def test_accept_sets_coach_user_and_coach_flag(self, organiser_client, sample_event, coach_user):
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
class VoteCoachTest:

    def test_vote_coach(self, organiser_client, past_assigned_event, coach_user):
        response = organiser_client.patch(
            f'/organiser/vote/{past_assigned_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 200
        coach_user.coach.refresh_from_db()
        assert coach_user.coach.votes == 1
        assert coach_user.coach.experience == 5

    def test_vote_coach_idempotent(self, organiser_client, past_assigned_event, coach_user):
        organiser_client.patch(
            f'/organiser/vote/{past_assigned_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        organiser_client.patch(
            f'/organiser/vote/{past_assigned_event.pk}/',
            {'experience': 3, 'flexibility': 3, 'reliability': 3},
            format='json',
        )
        coach_user.coach.refresh_from_db()
        assert coach_user.coach.votes == 1

    def test_vote_future_event_rejected(self, organiser_client, assigned_event):
        response = organiser_client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 400
        assert 'not happened yet' in response.data['error_msg']

    def test_get_coach_model(self, organiser_client, coach_user):
        response = organiser_client.get(f'/organiser/coach-model/{coach_user.pk}/')
        assert response.status_code == 200
        assert response.data['pk'] == coach_user.pk

    def test_vote_on_event_with_no_coach_returns_400(self, organiser_client, sample_event):
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

    def test_vote_with_missing_fields_returns_400(self, organiser_client, assigned_event):
        response = organiser_client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 5},
            format='json',
        )
        assert response.status_code == 400

    def test_vote_with_non_integer_returns_400(self, organiser_client, assigned_event):
        response = organiser_client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 'great', 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 400

    def test_other_organiser_cannot_vote(self, assigned_event, coach_user):
        other = User.objects.create_user(
            username='other_org_vote', password='pass', is_organiser=True,
        )
        Organiser.objects.create(user=other)
        token = Token.objects.create(user=other)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 403


@pytest.mark.django_db
class OrganiserPublicProfileTest:

    def test_coach_can_view_organiser_profile(self, coach_client, organiser_user):
        response = coach_client.get(f'/organiser/{organiser_user.pk}/')
        assert response.status_code == 200
        assert response.data['username'] == organiser_user.username

    def test_organiser_profile_not_found(self, coach_client):
        response = coach_client.get('/organiser/99999/')
        assert response.status_code == 404

    def test_unauthenticated_cannot_view_organiser_profile(self, api_client, organiser_user):
        response = api_client.get(f'/organiser/{organiser_user.pk}/')
        assert response.status_code == 401


@pytest.mark.django_db
class OrganiserPermissionsTest:

    def test_coach_cannot_access_organiser_profile(self, coach_client):
        response = coach_client.get('/organiser/')
        assert response.status_code == 403

    def test_coach_cannot_accept_offer(self, coach_client, sample_event, coach_user):
        response = coach_client.patch(
            f'/organiser/events/{sample_event.pk}/accept/{coach_user.pk}/',
        )
        assert response.status_code == 403
