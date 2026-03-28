import pytest

from app.models import Coach, User


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


@pytest.mark.django_db
class VoteCoachTest:

    def test_vote_coach(self, organiser_client, assigned_event, coach_user):
        response = organiser_client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        assert response.status_code == 200
        coach_user.coach.refresh_from_db()
        assert coach_user.coach.votes == 1
        assert coach_user.coach.experience == 5

    def test_vote_coach_idempotent(self, organiser_client, assigned_event, coach_user):
        organiser_client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        organiser_client.patch(
            f'/organiser/vote/{assigned_event.pk}/',
            {'experience': 3, 'flexibility': 3, 'reliability': 3},
            format='json',
        )
        coach_user.coach.refresh_from_db()
        assert coach_user.coach.votes == 1  # Only counted once

    def test_get_coach_model(self, organiser_client, coach_user):
        response = organiser_client.get(f'/organiser/coach-model/{coach_user.pk}/')
        assert response.status_code == 200
        assert response.data['pk'] == coach_user.pk


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
