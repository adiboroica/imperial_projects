import pytest
from datetime import date, time, timedelta
from unittest.mock import patch

from django.utils import timezone

from app.models import Coach, Event, Organiser, User
from app.services.coach import CoachServiceError, apply_to_event, cancel_assigned_event, get_feed_events, get_upcoming_jobs, unapply_from_event


@pytest.fixture
def org_user(db):
    user = User.objects.create_user(username='org', password='pass', is_organiser=True)
    Organiser.objects.create(user=user)
    return user


@pytest.fixture
def coach_user(db):
    user = User.objects.create_user(username='coach', password='pass', is_coach=True)
    Coach.objects.create(user=user)
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


@pytest.mark.django_db
class FeedTest:

    def test_returns_active_unassigned_events(self, org_user, coach_user):
        event = _make_event(org_user)
        result = list(get_feed_events(coach_user))
        assert event in result

    def test_excludes_assigned_events(self, org_user, coach_user):
        _make_event(org_user, coach_user=coach_user)
        result = list(get_feed_events(coach_user))
        assert len(result) == 0

    def test_excludes_blocked_organiser(self, org_user, coach_user):
        _make_event(org_user)
        org_user.organiser.blocked.add(coach_user)
        result = list(get_feed_events(coach_user))
        assert len(result) == 0

    def test_excludes_past_events(self, org_user, coach_user):
        _make_event(org_user, date=date.today() - timedelta(days=1))
        result = list(get_feed_events(coach_user))
        assert len(result) == 0

    def test_orders_by_date(self, org_user, coach_user):
        later = _make_event(org_user, name='Later', date=date.today() + timedelta(days=14))
        sooner = _make_event(org_user, name='Sooner', date=date.today() + timedelta(days=3))
        result = list(get_feed_events(coach_user))
        assert result[0].pk == sooner.pk
        assert result[1].pk == later.pk

    def test_empty_when_no_events(self, coach_user):
        result = list(get_feed_events(coach_user))
        assert result == []


@pytest.mark.django_db
class UpcomingJobsTest:

    def test_returns_assigned_active_events(self, org_user, coach_user):
        event = _make_event(org_user, coach_user=coach_user)
        result = list(get_upcoming_jobs(coach_user))
        assert event in result

    def test_excludes_other_coaches_events(self, org_user, coach_user):
        other = User.objects.create_user(username='other', password='pass', is_coach=True)
        _make_event(org_user, coach_user=other)
        result = list(get_upcoming_jobs(coach_user))
        assert len(result) == 0

    def test_empty_when_no_assignments(self, org_user, coach_user):
        _make_event(org_user)
        result = list(get_upcoming_jobs(coach_user))
        assert result == []


@pytest.mark.django_db
class ApplyTest:

    def test_adds_to_offers(self, org_user, coach_user):
        event = _make_event(org_user)
        apply_to_event(coach_user, event.pk)
        event.refresh_from_db()
        assert coach_user in event.offers.all()

    @patch('app.services.coach.notify_organiser_new_offer')
    def test_triggers_notification(self, mock_notify, org_user, coach_user):
        event = _make_event(org_user)
        apply_to_event(coach_user, event.pk)
        mock_notify.assert_called_once_with(org_user, coach_user, event)

    def test_rejects_assigned_event(self, org_user, coach_user):
        other = User.objects.create_user(username='other', password='pass', is_coach=True)
        event = _make_event(org_user, coach_user=other)
        with pytest.raises(CoachServiceError, match='already has a coach'):
            apply_to_event(coach_user, event.pk)

    def test_rejects_past_event(self, org_user, coach_user):
        event = _make_event(org_user, date=date.today() - timedelta(days=1))
        with pytest.raises(CoachServiceError, match='past'):
            apply_to_event(coach_user, event.pk)

    def test_rejects_blocked_coach(self, org_user, coach_user):
        org_user.organiser.blocked.add(coach_user)
        event = _make_event(org_user)
        with pytest.raises(CoachServiceError, match='blocked'):
            apply_to_event(coach_user, event.pk)
        assert coach_user not in event.offers.all()

    def test_rejects_duplicate_apply(self, org_user, coach_user):
        event = _make_event(org_user)
        event.offers.add(coach_user)
        with pytest.raises(CoachServiceError, match='Already applied'):
            apply_to_event(coach_user, event.pk)


@pytest.mark.django_db
class UnapplyTest:

    def test_removes_from_offers(self, org_user, coach_user):
        event = _make_event(org_user)
        event.offers.add(coach_user)
        unapply_from_event(coach_user, event.pk)
        assert coach_user not in event.offers.all()

    def test_noop_when_not_applied(self, org_user, coach_user):
        event = _make_event(org_user)
        unapply_from_event(coach_user, event.pk)
        assert coach_user not in event.offers.all()

    def test_nonexistent_event_raises(self, coach_user):
        with pytest.raises(CoachServiceError, match='not found'):
            unapply_from_event(coach_user, 99999)


@pytest.mark.django_db
class CancelTest:

    def test_nulls_coach_user(self, org_user, coach_user):
        event = _make_event(org_user, coach_user=coach_user)
        cancel_assigned_event(coach_user, event.pk)
        event.refresh_from_db()
        assert event.coach_user is None

    def test_removes_from_offers(self, org_user, coach_user):
        event = _make_event(org_user, coach_user=coach_user)
        event.offers.add(coach_user)
        cancel_assigned_event(coach_user, event.pk)
        assert coach_user not in event.offers.all()

    @patch('app.services.coach.notify_organiser_coach_cancelled')
    def test_triggers_notification(self, mock_notify, org_user, coach_user):
        event = _make_event(org_user, coach_user=coach_user)
        cancel_assigned_event(coach_user, event.pk)
        mock_notify.assert_called_once()

    def test_rejects_other_coach(self, org_user, coach_user):
        other = User.objects.create_user(username='other', password='pass', is_coach=True)
        event = _make_event(org_user, coach_user=other)
        with pytest.raises(CoachServiceError, match='Not your assignment'):
            cancel_assigned_event(coach_user, event.pk)

    def test_nonexistent_event_raises(self, coach_user):
        with pytest.raises(CoachServiceError, match='not found'):
            cancel_assigned_event(coach_user, 99999)
