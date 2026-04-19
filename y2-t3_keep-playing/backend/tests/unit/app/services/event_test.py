import pytest
from datetime import date, time, timedelta
from unittest.mock import patch

from django.utils import timezone

from app.models import Coach, Event, Organiser, User
from app.serializers import EventSerializer
from app.services.event import EventServiceError, create_event, delete_event, get_event_offers, get_event_organiser, get_organiser_events, validate_event_for_update


@pytest.fixture
def org_user(db):
    user = User.objects.create_user(username='org', password='pass', is_organiser=True)
    Organiser.objects.create(user=user)
    return user


def _make_event(org_user, **overrides):
    now = timezone.now()
    defaults = dict(
        name='Event',
        sport='Football',
        role='Coach',
        date=date.today() + timedelta(days=7),
        location='London',
        details='Details',
        price=50,
        start_time=time(10, 0),
        end_time=time(12, 0),
        flexible_start_time=time(9, 30),
        flexible_end_time=time(12, 30),
        organiser_user=org_user,
        creation_started=now,
        creation_ended=now,
    )
    defaults.update(overrides)
    return Event.objects.create(**defaults)


def _valid_event_data(org_user):
    now = timezone.now()
    return {
        'name': 'New Event',
        'sport': 'Tennis',
        'role': 'Coach',
        'date': (date.today() + timedelta(days=14)).isoformat(),
        'location': 'Court',
        'details': 'Details',
        'price': 30,
        'start_time': '10:00',
        'end_time': '12:00',
        'flexible_start_time': '09:30',
        'flexible_end_time': '12:30',
        'recurring': False,
        'organiser_user_id': org_user.pk,
        'creation_started': now.strftime('%Y-%m-%d %H:%M:%S'),
        'creation_ended': now.strftime('%Y-%m-%d %H:%M:%S'),
    }


@pytest.mark.django_db
class GetOrganiserEventsTest:

    def test_returns_events_for_organiser(self, org_user):
        event = _make_event(org_user)
        result = list(get_organiser_events(org_user))
        assert event in result

    def test_excludes_other_organisers_events(self, org_user):
        other = User.objects.create_user(username='other', password='pass', is_organiser=True)
        _make_event(other)
        result = list(get_organiser_events(org_user))
        assert len(result) == 0

    def test_orders_by_date(self, org_user):
        later = _make_event(org_user, name='Later', date=date.today() + timedelta(days=14))
        sooner = _make_event(org_user, name='Sooner', date=date.today() + timedelta(days=3))
        result = list(get_organiser_events(org_user))
        assert result[0].pk == sooner.pk
        assert result[1].pk == later.pk


@pytest.mark.django_db
class CreateEventTest:

    @patch('app.services.event.notify_favourites_of_new_event')
    def test_creates_event_and_notifies(self, mock_notify, org_user):
        data = _valid_event_data(org_user)
        serializer = EventSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        event = create_event(org_user, serializer.validated_data)
        assert event.pk is not None
        assert event.name == 'New Event'
        mock_notify.assert_called_once_with(org_user, event)


@pytest.mark.django_db
class DeleteEventTest:

    def test_deletes_event(self, org_user):
        event = _make_event(org_user)
        pk = event.pk
        delete_event(org_user, pk)
        assert not Event.objects.filter(pk=pk).exists()

    def test_rejects_other_organiser(self, org_user):
        other = User.objects.create_user(username='other', password='pass', is_organiser=True)
        Organiser.objects.create(user=other)
        event = _make_event(org_user)
        with pytest.raises(EventServiceError, match='Not your event'):
            delete_event(other, event.pk)
        assert Event.objects.filter(pk=event.pk).exists()


@pytest.mark.django_db
class UpdateEventTest:

    def test_returns_event_when_valid(self, org_user):
        event = _make_event(org_user)
        result = validate_event_for_update(org_user, event.pk)
        assert result.pk == event.pk

    def test_rejects_past_event(self, org_user):
        event = _make_event(org_user, date=date.today() - timedelta(days=1))
        with pytest.raises(EventServiceError, match='past'):
            validate_event_for_update(org_user, event.pk)

    def test_rejects_other_organiser(self, org_user):
        other = User.objects.create_user(username='other', password='pass', is_organiser=True)
        Organiser.objects.create(user=other)
        event = _make_event(org_user)
        with pytest.raises(EventServiceError, match='Not your event'):
            validate_event_for_update(other, event.pk)


@pytest.mark.django_db
class GetEventOffersTest:

    def test_returns_offer_users(self, org_user):
        coach_user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        Coach.objects.create(user=coach_user)
        event = _make_event(org_user)
        event.offers.add(coach_user)
        results = list(get_event_offers(org_user, event.pk))
        assert len(results) == 1
        assert results[0].username == 'coach'

    def test_returns_empty_when_no_offers(self, org_user):
        event = _make_event(org_user)
        results = list(get_event_offers(org_user, event.pk))
        assert results == []

    def test_rejects_other_organiser(self, org_user):
        other = User.objects.create_user(username='other', password='pass', is_organiser=True)
        Organiser.objects.create(user=other)
        event = _make_event(org_user)
        with pytest.raises(EventServiceError, match='Not your event'):
            get_event_offers(other, event.pk)

    def test_coach_relation_prefetched(self, org_user):
        coach_user = User.objects.create_user(username='coach2', password='pass', is_coach=True)
        Coach.objects.create(user=coach_user)
        event = _make_event(org_user)
        event.offers.add(coach_user)
        results = list(get_event_offers(org_user, event.pk))
        assert hasattr(results[0], 'coach')


@pytest.mark.django_db
class GetEventOrganiserTest:

    def test_returns_organiser(self, org_user):
        event = _make_event(org_user)
        result = get_event_organiser(event.pk)
        assert result == org_user
