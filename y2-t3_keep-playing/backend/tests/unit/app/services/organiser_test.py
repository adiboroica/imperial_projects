import pytest
from datetime import date, time, timedelta
from unittest.mock import patch

from django.utils import timezone

from app.models import Coach, Event, Organiser, User
from app.services.organiser import OrganiserServiceError, accept_offer, add_favourite, block_coach, remove_favourite, unblock_coach, vote_coach


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
class AcceptOfferTest:

    def test_sets_coach_and_clears_offers(self, org_user, coach_user):
        event = _make_event(org_user)
        other = User.objects.create_user(username='other', password='pass', is_coach=True)
        Coach.objects.create(user=other)
        event.offers.add(coach_user, other)
        accept_offer(org_user, event.pk, coach_user.pk)
        event.refresh_from_db()
        assert event.coach_user == coach_user
        assert event.offers.count() == 0

    @patch('app.services.organiser.notify_coach_offer_accepted')
    def test_triggers_notification(self, mock_notify, org_user, coach_user):
        event = _make_event(org_user)
        event.offers.add(coach_user)
        accept_offer(org_user, event.pk, coach_user.pk)
        mock_notify.assert_called_once_with(coach_user, event)

    def test_rejects_non_coach_user(self, org_user):
        regular = User.objects.create_user(username='regular', password='pass')
        event = _make_event(org_user)
        event.offers.add(regular)
        with pytest.raises(OrganiserServiceError, match='not a coach'):
            accept_offer(org_user, event.pk, regular.pk)

    def test_rejects_coach_not_in_offers(self, org_user, coach_user):
        event = _make_event(org_user)
        with pytest.raises(OrganiserServiceError, match='not applied'):
            accept_offer(org_user, event.pk, coach_user.pk)

    def test_rejects_other_organiser(self, org_user, coach_user):
        other_org = User.objects.create_user(username='other_org', password='pass', is_organiser=True)
        Organiser.objects.create(user=other_org)
        event = _make_event(org_user)
        event.offers.add(coach_user)
        with pytest.raises(OrganiserServiceError, match='Not your event'):
            accept_offer(other_org, event.pk, coach_user.pk)

    def test_rejects_already_assigned(self, org_user, coach_user):
        other = User.objects.create_user(username='other', password='pass', is_coach=True)
        event = _make_event(org_user, coach_user=other)
        event.offers.add(coach_user)
        with pytest.raises(OrganiserServiceError, match='already has a coach'):
            accept_offer(org_user, event.pk, coach_user.pk)

    def test_nonexistent_event_raises(self, org_user, coach_user):
        with pytest.raises(OrganiserServiceError, match='not found'):
            accept_offer(org_user, 99999, coach_user.pk)


@pytest.mark.django_db
class BlockUnblockTest:

    def test_block_adds_to_list(self, org_user, coach_user):
        block_coach(org_user, coach_user.pk)
        assert coach_user in org_user.organiser.blocked.all()

    def test_unblock_removes_from_list(self, org_user, coach_user):
        org_user.organiser.blocked.add(coach_user)
        unblock_coach(org_user, coach_user.pk)
        assert coach_user not in org_user.organiser.blocked.all()

    def test_unblock_noop_when_not_blocked(self, org_user, coach_user):
        unblock_coach(org_user, coach_user.pk)
        assert coach_user not in org_user.organiser.blocked.all()

    def test_block_removes_from_favourites(self, org_user, coach_user):
        org_user.organiser.favourites.add(coach_user)
        block_coach(org_user, coach_user.pk)
        assert coach_user in org_user.organiser.blocked.all()
        assert coach_user not in org_user.organiser.favourites.all()


@pytest.mark.django_db
class FavouritesTest:

    def test_add_favourite(self, org_user, coach_user):
        add_favourite(org_user, coach_user.pk)
        assert coach_user in org_user.organiser.favourites.all()

    def test_remove_favourite(self, org_user, coach_user):
        org_user.organiser.favourites.add(coach_user)
        remove_favourite(org_user, coach_user.pk)
        assert coach_user not in org_user.organiser.favourites.all()

    def test_remove_noop_when_not_favourited(self, org_user, coach_user):
        remove_favourite(org_user, coach_user.pk)
        assert coach_user not in org_user.organiser.favourites.all()

    def test_favourite_removes_from_blocked(self, org_user, coach_user):
        org_user.organiser.blocked.add(coach_user)
        add_favourite(org_user, coach_user.pk)
        assert coach_user in org_user.organiser.favourites.all()
        assert coach_user not in org_user.organiser.blocked.all()


@pytest.mark.django_db
class VoteCoachTest:

    @pytest.fixture
    def past_event(self, org_user, coach_user):
        return _make_event(
            org_user,
            coach_user=coach_user,
            date=date.today() - timedelta(days=7),
        )

    def test_increments_ratings(self, org_user, coach_user, past_event):
        vote_coach(org_user, past_event.pk, 5, 4, 3)
        coach_user.coach.refresh_from_db()
        assert coach_user.coach.votes == 1
        assert coach_user.coach.experience == 5
        assert coach_user.coach.flexibility == 4
        assert coach_user.coach.reliability == 3

    def test_marks_event_as_voted(self, org_user, coach_user, past_event):
        vote_coach(org_user, past_event.pk, 5, 4, 3)
        past_event.refresh_from_db()
        assert past_event.voted is True

    def test_rejects_future_event(self, org_user, coach_user):
        future = _make_event(org_user, coach_user=coach_user)
        with pytest.raises(OrganiserServiceError, match='not happened yet'):
            vote_coach(org_user, future.pk, 5, 4, 3)

    def test_rejects_double_vote(self, org_user, coach_user, past_event):
        vote_coach(org_user, past_event.pk, 5, 4, 3)
        with pytest.raises(OrganiserServiceError, match='already been rated'):
            vote_coach(org_user, past_event.pk, 3, 3, 3)

    def test_rejects_no_coach(self, org_user):
        event = _make_event(org_user, date=date.today() - timedelta(days=7))
        with pytest.raises(OrganiserServiceError, match='no assigned coach'):
            vote_coach(org_user, event.pk, 5, 4, 3)

    def test_rejects_other_organiser(self, org_user, coach_user, past_event):
        other = User.objects.create_user(username='other_org', password='pass', is_organiser=True)
        Organiser.objects.create(user=other)
        with pytest.raises(OrganiserServiceError, match='Not your event'):
            vote_coach(other, past_event.pk, 5, 4, 3)

    def test_nonexistent_event_raises(self, org_user):
        with pytest.raises(OrganiserServiceError, match='not found'):
            vote_coach(org_user, 99999, 5, 4, 3)

    def test_boundary_scores_accepted(self, org_user, coach_user, past_event):
        vote_coach(org_user, past_event.pk, 1, 1, 5)
        coach_user.coach.refresh_from_db()
        assert coach_user.coach.experience == 1
        assert coach_user.coach.reliability == 5
