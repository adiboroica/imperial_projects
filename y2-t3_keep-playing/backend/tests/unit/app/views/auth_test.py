import pytest
from rest_framework.test import APIRequestFactory, force_authenticate
from rest_framework.authtoken.models import Token
from rest_framework.throttling import AnonRateThrottle

from app.models import Coach, Organiser, User
from app.views.auth import CreateCoachUser, CreateOrganiserUser, HelloView, LogoutView, ThrottledObtainAuthToken


@pytest.mark.django_db
class CreateCoachUserViewTest:

    def test_valid_data_returns_201(self):
        factory = APIRequestFactory()
        request = factory.post('/new_coach/', {
            'username': 'newcoach',
            'password': 'Str0ngP@ss!',
        })
        response = CreateCoachUser.as_view()(request)
        assert response.status_code == 201
        assert User.objects.filter(username='newcoach').exists()
        assert Coach.objects.filter(user__username='newcoach').exists()

    def test_invalid_data_returns_400(self):
        factory = APIRequestFactory()
        request = factory.post('/new_coach/', {
            'username': '',
            'password': '',
        })
        response = CreateCoachUser.as_view()(request)
        assert response.status_code == 400
        assert response.data.get('error') is True


@pytest.mark.django_db
class CreateOrganiserUserViewTest:

    def test_valid_data_returns_201(self):
        factory = APIRequestFactory()
        request = factory.post('/new_organiser/', {
            'username': 'neworg',
            'password': 'Str0ngP@ss!',
        }, format='json')
        response = CreateOrganiserUser.as_view()(request)
        assert response.status_code == 201
        assert User.objects.filter(username='neworg').exists()
        assert Organiser.objects.filter(user__username='neworg').exists()

    def test_invalid_data_returns_400(self):
        factory = APIRequestFactory()
        request = factory.post('/new_organiser/', {
            'username': '',
            'password': '',
        }, format='json')
        response = CreateOrganiserUser.as_view()(request)
        assert response.status_code == 400


@pytest.mark.django_db
class HelloViewTest:

    def test_returns_greeting(self):
        user = User.objects.create_user(username='greeter', password='pass')
        factory = APIRequestFactory()
        request = factory.get('/hello/')
        request.user = user
        # Force authentication so permission check passes
        from rest_framework.test import force_authenticate
        force_authenticate(request, user=user)
        response = HelloView.as_view()(request)
        assert response.status_code == 200
        assert 'greeter' in response.data


class ThrottledLoginViewTest:

    def test_has_anon_throttle(self):
        assert AnonRateThrottle in ThrottledObtainAuthToken.throttle_classes


@pytest.mark.django_db
class LogoutViewTest:

    def test_logout_deletes_token(self):
        user = User.objects.create_user(username='logoutuser', password='pass')
        Token.objects.create(user=user)
        assert Token.objects.filter(user=user).exists()
        factory = APIRequestFactory()
        request = factory.post('/logout/')
        force_authenticate(request, user=user)
        response = LogoutView.as_view()(request)
        assert response.status_code == 200
        assert not Token.objects.filter(user=user).exists()
