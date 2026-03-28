import pytest
from rest_framework.test import APIClient

from app.models import Coach, Organiser, User


@pytest.mark.django_db
class AuthTest:

    def test_register_coach(self):
        client = APIClient()
        response = client.post('/new_coach/', {
            'username': 'newcoach',
            'password': 'secret123',
        })
        assert response.status_code == 200
        user = User.objects.get(username='newcoach')
        assert user.is_coach is True
        assert Coach.objects.filter(user=user).exists()

    def test_register_organiser(self):
        client = APIClient()
        response = client.post('/new_organiser/', {
            'username': 'neworg',
            'password': 'secret123',
        }, format='json')
        assert response.status_code == 200
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
