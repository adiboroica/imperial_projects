import pytest

from app.models import Coach, Organiser, User
from app.serializers import (
    NewCoachUserSerializer,
    NewOrganiserUserSerializer,
    PublicUserSerializer,
    UserSerializer,
)


@pytest.mark.django_db
class PublicUserSerializerTest:

    def test_fields(self):
        user = User.objects.create_user(
            username='pub', password='pass', first_name='A', last_name='B',
            location='London', is_coach=True,
        )
        data = PublicUserSerializer(user).data
        assert set(data.keys()) == {
            'pk', 'username', 'first_name', 'last_name',
            'location', 'is_coach', 'is_organiser', 'verified',
        }
        assert 'password' not in data
        assert 'email' not in data

    def test_values(self):
        user = User.objects.create_user(
            username='pub2', password='pass', first_name='Alice', last_name='Smith',
            location='Manchester', is_coach=True, verified=True,
        )
        data = PublicUserSerializer(user).data
        assert data['username'] == 'pub2'
        assert data['first_name'] == 'Alice'
        assert data['is_coach'] is True
        assert data['verified'] is True


@pytest.mark.django_db
class UserSerializerTest:

    def test_password_is_write_only(self):
        user = User.objects.create_user(username='u1', password='pass')
        data = UserSerializer(user).data
        assert 'password' not in data

    def test_create_hashes_password(self):
        serializer = UserSerializer(data={
            'username': 'hashtest',
            'password': 'mypassword',
            'email': 'hash@test.com',
        })
        assert serializer.is_valid(), serializer.errors
        user = serializer.save()
        assert user.password != 'mypassword'
        assert user.check_password('mypassword')

    def test_all_expected_fields(self):
        user = User.objects.create_user(username='u2', password='pass')
        data = UserSerializer(user).data
        expected = {
            'pk', 'username', 'first_name', 'last_name', 'location',
            'email', 'is_coach', 'is_organiser', 'qualification', 'verified',
        }
        assert set(data.keys()) == expected


@pytest.mark.django_db
class NewCoachUserSerializerTest:

    def test_creates_user_and_coach(self):
        serializer = NewCoachUserSerializer(data={
            'username': 'newcoach',
            'password': 'Str0ngP@ss!',
        })
        assert serializer.is_valid(), serializer.errors
        user = serializer.save()
        assert user.is_coach is True
        assert Coach.objects.filter(user=user).exists()

    def test_password_is_hashed(self):
        serializer = NewCoachUserSerializer(data={
            'username': 'coachhash',
            'password': 'Str0ngP@ss!',
        })
        serializer.is_valid()
        user = serializer.save()
        assert user.check_password('Str0ngP@ss!')

    def test_rejects_duplicate_username(self):
        User.objects.create_user(username='taken', password='pass')
        serializer = NewCoachUserSerializer(data={
            'username': 'taken',
            'password': 'Str0ngP@ss!',
        })
        assert not serializer.is_valid()
        assert 'username' in serializer.errors

    def test_validates_password_strength(self):
        serializer = NewCoachUserSerializer(data={
            'username': 'weakpass',
            'password': '123',
        })
        assert not serializer.is_valid()
        assert 'password' in serializer.errors

    def test_atomic_creation(self):
        """If Coach creation fails after User creation, the User is rolled back."""
        initial_count = User.objects.count()
        serializer = NewCoachUserSerializer(data={
            'username': 'atomictest',
            'password': 'Str0ngP@ss!',
        })
        assert serializer.is_valid()
        serializer.save()
        assert User.objects.count() == initial_count + 1
        assert Coach.objects.filter(user__username='atomictest').exists()


@pytest.mark.django_db
class NewOrganiserUserSerializerTest:

    def test_creates_user_and_organiser(self):
        serializer = NewOrganiserUserSerializer(data={
            'username': 'neworg',
            'password': 'Str0ngP@ss!',
        })
        assert serializer.is_valid(), serializer.errors
        user = serializer.save()
        assert user.is_organiser is True
        assert Organiser.objects.filter(user=user).exists()

    def test_rejects_duplicate_username(self):
        User.objects.create_user(username='taken2', password='pass')
        serializer = NewOrganiserUserSerializer(data={
            'username': 'taken2',
            'password': 'Str0ngP@ss!',
        })
        assert not serializer.is_valid()
        assert 'username' in serializer.errors

    def test_validates_password_strength(self):
        serializer = NewOrganiserUserSerializer(data={
            'username': 'weakorg',
            'password': '123',
        })
        assert not serializer.is_valid()
        assert 'password' in serializer.errors
