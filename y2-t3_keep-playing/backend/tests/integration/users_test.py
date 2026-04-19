import pytest

from app.models import User


@pytest.mark.django_db
class UsersListTest:

    def test_get_users_returns_coaches_only(self, organiser_client, organiser_user, coach_user):
        response = organiser_client.get('/users/')
        assert response.status_code == 200
        usernames = [u['username'] for u in response.data]
        assert coach_user.username in usernames
        assert organiser_user.username not in usernames

    def test_get_users_excludes_password(self, organiser_client, coach_user):
        response = organiser_client.get('/users/')
        assert response.status_code == 200
        assert len(response.data) > 0
        for user_data in response.data:
            assert 'password' not in user_data

    def test_get_users_unauthenticated(self, api_client):
        response = api_client.get('/users/')
        assert response.status_code == 401


@pytest.mark.django_db
class UserCreateForbiddenTest:
    """POST /user/ no longer exists — registration must go through /new_coach/ or /new_organiser/."""

    def test_post_user_not_allowed(self, organiser_client):
        response = organiser_client.post('/user/', {
            'username': 'newuser',
            'password': 'secret123',
        }, format='json')
        assert response.status_code == 405


@pytest.mark.django_db
class UserPatchTest:

    def test_patch_user_profile(self, organiser_client, organiser_user):
        response = organiser_client.patch('/user/', {
            'first_name': 'Updated',
            'location': 'Manchester',
        }, format='json')
        assert response.status_code == 200
        organiser_user.refresh_from_db()
        assert organiser_user.first_name == 'Updated'
        assert organiser_user.location == 'Manchester'

    def test_patch_strips_role_flags(self, organiser_client, organiser_user):
        response = organiser_client.patch('/user/', {
            'is_coach': True,
            'is_organiser': False,
            'verified': True,
        }, format='json')
        assert response.status_code == 200
        organiser_user.refresh_from_db()
        assert organiser_user.is_coach is False
        assert organiser_user.is_organiser is True
        assert organiser_user.verified is False

    def test_patch_strips_password(self, organiser_client, organiser_user):
        old_password = organiser_user.password
        organiser_client.patch('/user/', {
            'password': 'hackednewpass',
        }, format='json')
        organiser_user.refresh_from_db()
        assert organiser_user.password == old_password
