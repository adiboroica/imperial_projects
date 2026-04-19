import pytest
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient

from app.models import Coach, Organiser, User


@pytest.mark.django_db
class AuthTest:

    def test_register_coach(self):
        client = APIClient()
        response = client.post('/new_coach/', {
            'username': 'newcoach',
            'password': 'Str0ngP@ss!',
        })
        assert response.status_code == 201
        user = User.objects.get(username='newcoach')
        assert user.is_coach is True
        assert Coach.objects.filter(user=user).exists()

    def test_register_organiser(self):
        client = APIClient()
        response = client.post('/new_organiser/', {
            'username': 'neworg',
            'password': 'Str0ngP@ss!',
        }, format='json')
        assert response.status_code == 201
        user = User.objects.get(username='neworg')
        assert user.is_organiser is True
        assert Organiser.objects.filter(user=user).exists()

    def test_login_returns_token(self):
        User.objects.create_user(username='loginuser', password='pass123')
        client = APIClient()
        response = client.post('/login/', {
            'username': 'loginuser',
            'password': 'pass123',
        })
        assert response.status_code == 200
        assert 'token' in response.data

    def test_login_invalid_credentials(self):
        client = APIClient()
        response = client.post('/login/', {
            'username': 'nouser',
            'password': 'wrong',
        })
        assert response.status_code == 400

    def test_unauthenticated_access_denied(self):
        client = APIClient()
        response = client.get('/user/')
        assert response.status_code == 401

    def test_authenticated_access_allowed(self):
        from rest_framework.authtoken.models import Token
        user = User.objects.create_user(username='authuser', password='pass123')
        token = Token.objects.create(user=user)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.get('/user/')
        assert response.status_code == 200
        assert response.data['username'] == 'authuser'

    def test_duplicate_username_coach_registration(self):
        """Registering a coach with an existing username should fail with 400, not 500."""
        User.objects.create_user(username='taken', password='pass')
        client = APIClient()
        response = client.post('/new_coach/', {
            'username': 'taken',
            'password': 'pass',
        })
        assert response.status_code == 400

    def test_duplicate_username_organiser_registration(self):
        User.objects.create_user(username='taken2', password='pass')
        client = APIClient()
        response = client.post('/new_organiser/', {
            'username': 'taken2',
            'password': 'pass',
        }, format='json')
        assert response.status_code == 400

    def test_hello_returns_greeting(self):
        user = User.objects.create_user(username='greeter', password='pass')
        token = Token.objects.create(user=user)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.get('/hello/')
        assert response.status_code == 200
        assert 'greeter' in response.data

    def test_hello_unauthenticated(self):
        client = APIClient()
        response = client.get('/hello/')
        assert response.status_code == 401

    def test_logout_deletes_token(self):
        user = User.objects.create_user(username='logoutuser', password='pass')
        token = Token.objects.create(user=user)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.post('/logout/')
        assert response.status_code == 200
        assert not Token.objects.filter(user=user).exists()

    def test_logout_unauthenticated(self):
        client = APIClient()
        response = client.post('/logout/')
        assert response.status_code == 401

    def test_token_unusable_after_logout(self):
        user = User.objects.create_user(username='logoutuser2', password='pass')
        token = Token.objects.create(user=user)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        client.post('/logout/')
        response = client.get('/user/')
        assert response.status_code == 401
