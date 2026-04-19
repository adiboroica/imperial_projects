import pytest
from datetime import date, time, timedelta

from django.utils import timezone

from app.models import Event, User
from app.services.temporal import active_event_q, is_event_active, is_event_concluded


@pytest.mark.django_db
class ActiveEventQueryTest:
    """Tests for active_event_q and is_event_active."""

    @pytest.fixture
    def org_user(self):
        return User.objects.create_user(username='org', password='pass', is_organiser=True)

    def _make_event(self, org_user, **overrides):
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

    def test_future_non_recurring_included(self, org_user):
        event = self._make_event(org_user, date=date.today() + timedelta(days=7))
        qs = Event.objects.filter(active_event_q())
        assert event in qs
        assert is_event_active(event) is True

    def test_past_non_recurring_excluded(self, org_user):
        event = self._make_event(org_user, date=date.today() - timedelta(days=1))
        qs = Event.objects.filter(active_event_q())
        assert event not in qs
        assert is_event_active(event) is False

    def test_recurring_no_end_date_included(self, org_user):
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=None,
            date=date.today() - timedelta(days=30),
        )
        qs = Event.objects.filter(active_event_q())
        assert event in qs
        assert is_event_active(event) is True

    def test_recurring_past_end_date_excluded(self, org_user):
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=date.today() - timedelta(days=1),
            date=date.today() - timedelta(days=30),
        )
        qs = Event.objects.filter(active_event_q())
        assert event not in qs
        assert is_event_active(event) is False

    def test_recurring_future_end_date_included(self, org_user):
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=date.today() + timedelta(days=30),
            date=date.today() - timedelta(days=7),
        )
        qs = Event.objects.filter(active_event_q())
        assert event in qs
        assert is_event_active(event) is True


@pytest.mark.django_db
class EventConcludedTest:
    """Tests for is_event_concluded."""

    @pytest.fixture
    def org_user(self):
        return User.objects.create_user(username='org2', password='pass', is_organiser=True)

    def _make_event(self, org_user, **overrides):
        now = timezone.now()
        defaults = dict(
            name='Event',
            sport='Football',
            role='Coach',
            date=date.today(),
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

    def test_past_date_concluded(self, org_user):
        event = self._make_event(org_user, date=date.today() - timedelta(days=7))
        assert is_event_concluded(event) is True

    def test_future_date_not_concluded(self, org_user):
        event = self._make_event(org_user, date=date.today() + timedelta(days=7))
        assert is_event_concluded(event) is False

    def test_recurring_past_end_date_concluded(self, org_user):
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=date.today() - timedelta(days=1),
            date=date.today() - timedelta(days=30),
        )
        assert is_event_concluded(event) is True

    def test_recurring_future_start_not_concluded(self, org_user):
        event = self._make_event(
            org_user,
            recurring=True,
            date=date.today() + timedelta(days=7),
        )
        assert is_event_concluded(event) is False

    def test_recurring_concluded_different_weekday(self, org_user):
        """A recurring event whose start date is 1-6 days ago and today is
        a different weekday has already had at least one occurrence end."""
        # Pick a date 3 days ago (guaranteed different weekday unless it wraps
        # around to the same day, so use 3 which avoids 0 mod 7).
        past_date = date.today() - timedelta(days=3)
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=None,
            date=past_date,
        )
        assert is_event_concluded(event) is True

    def test_recurring_not_concluded_same_weekday_before_end(self, org_user):
        """On the recurring day, if end_time hasn't passed, not concluded."""
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=None,
            date=date.today() - timedelta(days=7),
            end_time=time(23, 59),
        )
        assert is_event_concluded(event) is False

    def test_recurring_concluded_same_weekday_after_end(self, org_user):
        """On the recurring day, if end_time has passed, concluded."""
        event = self._make_event(
            org_user,
            recurring=True,
            recurring_end_date=None,
            date=date.today() - timedelta(days=7),
            end_time=time(0, 1),
        )
        assert is_event_concluded(event) is True
