import pytest

from app.models import User


@pytest.mark.django_db
class UserModelTest:

    def test_create_user(self):
        user = User.objects.create_user(username='testuser', password='pass123')
        assert user.pk is not None
        assert str(user) == 'testuser'

    def test_defaults(self):
        user = User.objects.create_user(username='defaults', password='pass')
        assert user.is_coach is False
        assert user.is_organiser is False
        assert user.verified is False
        assert user.location == ''
        assert user.qualification is None or not user.qualification

    def test_both_roles(self):
        user = User.objects.create_user(
            username='both', password='pass', is_coach=True, is_organiser=True,
        )
        assert user.is_coach is True
        assert user.is_organiser is True

    def test_location_and_qualification(self):
        user = User.objects.create_user(
            username='located', password='pass', location='London',
        )
        assert user.location == 'London'
        assert not user.qualification
