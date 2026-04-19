import pytest
from datetime import date, time, timedelta
from django.utils import timezone

from app.models import Event, User
from app.serializers import EventSerializer


@pytest.mark.django_db
class EventSerializerValidationTest:

    @pytest.fixture
    def org_user(self):
        return User.objects.create_user(username='org', password='pass', is_organiser=True)

    def _valid_data(self, org_user):
        now = timezone.now()
        return {
            'name': 'Test Event',
            'sport': 'Football',
            'role': 'Coach',
            'date': (date.today() + timedelta(days=7)).isoformat(),
            'location': 'London',
            'details': 'Details',
            'price': 50,
            'start_time': '10:00',
            'end_time': '12:00',
            'flexible_start_time': '09:30',
            'flexible_end_time': '12:30',
            'recurring': False,
            'organiser_user_id': org_user.pk,
            'creation_started': now.strftime('%Y-%m-%d %H:%M:%S'),
            'creation_ended': now.strftime('%Y-%m-%d %H:%M:%S'),
        }

    def test_valid_data(self, org_user):
        serializer = EventSerializer(data=self._valid_data(org_user))
        assert serializer.is_valid(), serializer.errors

    def test_rejects_past_date(self, org_user):
        data = self._valid_data(org_user)
        data['date'] = (date.today() - timedelta(days=1)).isoformat()
        serializer = EventSerializer(data=data)
        assert not serializer.is_valid()
        assert 'date' in serializer.errors

    def test_accepts_today(self, org_user):
        data = self._valid_data(org_user)
        data['date'] = date.today().isoformat()
        serializer = EventSerializer(data=data)
        assert serializer.is_valid(), serializer.errors

    def test_rejects_negative_price(self, org_user):
        data = self._valid_data(org_user)
        data['price'] = -1
        serializer = EventSerializer(data=data)
        assert not serializer.is_valid()
        assert 'price' in serializer.errors

    def test_accepts_zero_price(self, org_user):
        data = self._valid_data(org_user)
        data['price'] = 0
        serializer = EventSerializer(data=data)
        assert serializer.is_valid(), serializer.errors

    def test_rejects_end_before_start(self, org_user):
        data = self._valid_data(org_user)
        data['start_time'] = '14:00'
        data['end_time'] = '12:00'
        serializer = EventSerializer(data=data)
        assert not serializer.is_valid()
        assert 'end_time' in serializer.errors

    def test_rejects_flex_end_before_flex_start(self, org_user):
        data = self._valid_data(org_user)
        data['flexible_start_time'] = '14:00'
        data['flexible_end_time'] = '12:00'
        serializer = EventSerializer(data=data)
        assert not serializer.is_valid()
        assert 'flexible_end_time' in serializer.errors


@pytest.mark.django_db
class EventSerializerFieldsTest:

    def test_read_only_fields(self, org_user):
        """coach, coach_user, voted, offers cannot be set via serializer."""
        now = timezone.now()
        coach_user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        data = {
            'name': 'ReadOnly Test',
            'sport': 'Tennis',
            'role': 'Coach',
            'date': (date.today() + timedelta(days=7)).isoformat(),
            'location': 'Court',
            'details': 'Test details',
            'price': 30,
            'start_time': '10:00',
            'end_time': '12:00',
            'flexible_start_time': '09:30',
            'flexible_end_time': '12:30',
            'recurring': False,
            'organiser_user_id': org_user.pk,
            'creation_started': now.strftime('%Y-%m-%d %H:%M:%S'),
            'creation_ended': now.strftime('%Y-%m-%d %H:%M:%S'),
            # These should be ignored:
            'coach_user': coach_user.pk,
            'voted': True,
        }
        serializer = EventSerializer(data=data)
        assert serializer.is_valid(), serializer.errors
        event = serializer.save()
        assert event.coach_user is None
        assert event.voted is False

    @pytest.fixture
    def org_user(self):
        return User.objects.create_user(username='org_ro', password='pass', is_organiser=True)

    def test_create_sets_organiser(self, org_user):
        now = timezone.now()
        data = {
            'name': 'Create Test',
            'sport': 'Football',
            'role': 'Coach',
            'date': (date.today() + timedelta(days=7)).isoformat(),
            'location': 'Stadium',
            'details': 'Test details',
            'price': 50,
            'start_time': '10:00',
            'end_time': '12:00',
            'flexible_start_time': '09:30',
            'flexible_end_time': '12:30',
            'recurring': False,
            'organiser_user_id': org_user.pk,
            'creation_started': now.strftime('%Y-%m-%d %H:%M:%S'),
            'creation_ended': now.strftime('%Y-%m-%d %H:%M:%S'),
        }
        serializer = EventSerializer(data=data)
        assert serializer.is_valid(), serializer.errors
        event = serializer.save()
        assert event.organiser_user == org_user
