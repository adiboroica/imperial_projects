import pytest
from datetime import date, time

from app.models import Event, User


@pytest.mark.django_db
class EventModelTest:

    @pytest.fixture
    def org_user(self):
        return User.objects.create_user(username='org', password='pass', is_organiser=True)

    @pytest.fixture
    def coach_user(self):
        return User.objects.create_user(username='coach', password='pass', is_coach=True)

    def _make_event(self, org_user, **overrides):
        defaults = dict(
            name='Test Event',
            date=date.today(),
            location='London',
            details='Details',
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 30),
            flexible_end_time=time(12, 30),
            price=50,
            sport='Football',
            role='Coach',
            organiser_user=org_user,
        )
        defaults.update(overrides)
        return Event.objects.create(**defaults)

    def test_create_event(self, org_user):
        event = self._make_event(org_user)
        assert str(event) == f'Test Event ({date.today()})'
        assert event.pk is not None

    def test_coach_property_false_when_no_coach(self, org_user):
        event = self._make_event(org_user)
        assert event.coach is False
        assert event.coach_user is None

    def test_coach_property_true_when_assigned(self, org_user, coach_user):
        event = self._make_event(org_user, coach_user=coach_user)
        assert event.coach is True

    def test_offers_m2m(self, org_user, coach_user):
        event = self._make_event(org_user)
        event.offers.add(coach_user)
        assert coach_user in event.offers.all()

        event.offers.remove(coach_user)
        assert coach_user not in event.offers.all()

    def test_coach_user_set_null_on_delete(self, org_user, coach_user):
        event = self._make_event(org_user, coach_user=coach_user)
        coach_user.delete()
        event.refresh_from_db()
        assert event.coach_user is None

    def test_organiser_user_cascade_on_delete(self, org_user):
        event = self._make_event(org_user)
        event_pk = event.pk
        org_user.delete()
        assert not Event.objects.filter(pk=event_pk).exists()

    def test_recurring_defaults(self, org_user):
        event = self._make_event(org_user)
        assert event.recurring is False
        assert event.recurring_end_date is None

    def test_voted_default(self, org_user):
        event = self._make_event(org_user)
        assert event.voted is False
