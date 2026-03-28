import pytest
from datetime import date, time, timedelta
from django.utils import timezone
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient

from app.models import Coach, Event, Organiser, User


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def organiser_user(db):
    user = User.objects.create_user(
        username='organiser1',
        password='testpass123',
        first_name='Alice',
        last_name='Smith',
        email='alice@test.com',
        location='London',
        is_organiser=True,
    )
    Organiser.objects.create(user=user)
    return user


@pytest.fixture
def organiser_token(organiser_user):
    token, _ = Token.objects.get_or_create(user=organiser_user)
    return token.key


@pytest.fixture
def organiser_client(api_client, organiser_token):
    api_client.credentials(HTTP_AUTHORIZATION=f'Token {organiser_token}')
    return api_client


@pytest.fixture
def coach_user(db):
    user = User.objects.create_user(
        username='coach1',
        password='testpass123',
        first_name='Bob',
        last_name='Jones',
        email='bob@test.com',
        location='London',
        is_coach=True,
        verified=True,
    )
    Coach.objects.create(user=user)
    return user


@pytest.fixture
def coach_token(coach_user):
    token, _ = Token.objects.get_or_create(user=coach_user)
    return token.key


@pytest.fixture
def coach_client(api_client, coach_token):
    api_client.credentials(HTTP_AUTHORIZATION=f'Token {coach_token}')
    return api_client


@pytest.fixture
def coach_user2(db):
    user = User.objects.create_user(
        username='coach2',
        password='testpass123',
        first_name='Charlie',
        last_name='Brown',
        email='charlie@test.com',
        location='Manchester',
        is_coach=True,
    )
    Coach.objects.create(user=user)
    return user


@pytest.fixture
def sample_event(organiser_user):
    today = date.today()
    now = timezone.now()
    return Event.objects.create(
        name='Football Training',
        sport='Football',
        role='Coach',
        date=today + timedelta(days=14),
        location='Sports Centre',
        details='Weekly training',
        price=50,
        coach=False,
        start_time=time(10, 0),
        end_time=time(12, 0),
        flexible_start_time=time(9, 30),
        flexible_end_time=time(12, 30),
        organiser_user=organiser_user,
        creation_started=now,
        creation_ended=now,
    )


@pytest.fixture
def assigned_event(organiser_user, coach_user):
    today = date.today()
    now = timezone.now()
    return Event.objects.create(
        name='Swimming Lessons',
        sport='Swimming',
        role='Coach',
        date=today + timedelta(days=7),
        location='Aquatics Centre',
        details='Lessons for kids',
        price=40,
        coach=True,
        coach_user=coach_user,
        start_time=time(9, 0),
        end_time=time(10, 30),
        flexible_start_time=time(8, 30),
        flexible_end_time=time(11, 0),
        organiser_user=organiser_user,
        creation_started=now,
        creation_ended=now,
    )
