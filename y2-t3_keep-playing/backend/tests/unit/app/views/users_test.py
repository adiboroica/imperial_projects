import pytest

from rest_framework.test import APIRequestFactory, force_authenticate

from app.models import Coach, User
from app.views.users import UserRecordView, UsersRecordView


@pytest.mark.django_db
class UserRecordPatchStrippingTest:
    """UserRecordView.patch strips role flags and password."""

    def test_strips_role_flags_and_password(self):
        user = User.objects.create_user(username='patchme', password='original')
        factory = APIRequestFactory()
        request = factory.patch('/user/', {
            'first_name': 'Updated',
            'is_coach': True,
            'is_organiser': True,
            'verified': True,
            'password': 'newpass',
        }, format='json')
        force_authenticate(request, user=user)
        response = UserRecordView.as_view()(request)
        assert response.status_code == 200
        user.refresh_from_db()
        assert user.first_name == 'Updated'
        assert user.is_coach is False
        assert user.is_organiser is False
        assert user.verified is False
        assert user.check_password('original')


@pytest.mark.django_db
class UsersRecordGetTest:
    """UsersRecordView.get returns only coaches."""

    def test_returns_only_coaches(self):
        coach = User.objects.create_user(username='coach', password='pass', is_coach=True)
        Coach.objects.create(user=coach)
        organiser = User.objects.create_user(username='org', password='pass', is_organiser=True)

        factory = APIRequestFactory()
        request = factory.get('/users/')
        force_authenticate(request, user=organiser)
        response = UsersRecordView.as_view()(request)
        assert response.status_code == 200
        usernames = [u['username'] for u in response.data]
        assert 'coach' in usernames
        assert 'org' not in usernames
