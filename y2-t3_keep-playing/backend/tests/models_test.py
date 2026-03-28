import pytest
from datetime import date, time, datetime

from app.models import Coach, Event, Organiser, User


@pytest.mark.django_db
class ModelsTest:

    def test_create_user(self):
        user = User.objects.create_user(username='testuser', password='pass123')
        assert user.pk is not None
        assert str(user) == 'testuser'
        assert user.is_coach is False
        assert user.is_organiser is False

    def test_create_organiser(self):
        user = User.objects.create_user(username='org', password='pass', is_organiser=True)
        organiser = Organiser.objects.create(user=user)
        assert str(organiser) == 'Organiser: org'
        assert organiser.user == user

    def test_create_coach(self):
        user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        coach = Coach.objects.create(user=user)
        assert str(coach) == 'Coach: coach'
        assert coach.votes == 0
        assert coach.experience == 0

    def test_create_event(self):
        user = User.objects.create_user(username='org2', password='pass', is_organiser=True)
        event = Event.objects.create(
            name='Test Event',
            date=date.today(),
            location='London',
            details='Details',
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 30),
            flexible_end_time=time(12, 30),
            coach=False,
            price=50,
            sport='Football',
            role='Coach',
            organiser_user=user,
        )
        assert str(event) == f'Test Event ({date.today()})'
        assert event.coach is False
        assert event.coach_user is None

    def test_organiser_favourites_and_blocked(self):
        org_user = User.objects.create_user(username='org3', password='pass', is_organiser=True)
        coach_user = User.objects.create_user(username='coach3', password='pass', is_coach=True)
        organiser = Organiser.objects.create(user=org_user)

        organiser.favourites.add(coach_user)
        assert coach_user in organiser.favourites.all()

        organiser.blocked.add(coach_user)
        assert coach_user in organiser.blocked.all()

    def test_event_offers_m2m(self):
        org_user = User.objects.create_user(username='org4', password='pass', is_organiser=True)
        coach_user = User.objects.create_user(username='coach4', password='pass', is_coach=True)
        event = Event.objects.create(
            name='M2M Test',
            date=date.today(),
            location='London',
            details='',
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 30),
            flexible_end_time=time(12, 30),
            coach=False,
            price=0,
            sport='Tennis',
            role='Coach',
            organiser_user=org_user,
        )
        event.offers.add(coach_user)
        assert coach_user in event.offers.all()

    def test_event_coach_user_set_null_on_delete(self):
        org_user = User.objects.create_user(username='org5', password='pass')
        coach_user = User.objects.create_user(username='coach5', password='pass')
        event = Event.objects.create(
            name='SetNull Test',
            date=date.today(),
            location='London',
            details='',
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 30),
            flexible_end_time=time(12, 30),
            coach=True,
            coach_user=coach_user,
            price=0,
            sport='Tennis',
            role='Coach',
            organiser_user=org_user,
        )
        coach_user.delete()
        event.refresh_from_db()
        assert event.coach_user is None
