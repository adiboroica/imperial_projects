from django.db import transaction

from app.email import notify_organiser_coach_cancelled, notify_organiser_new_offer
from app.models import Coach, Event, Organiser, User
from app.services._errors import BaseServiceError
from app.services.temporal import active_event_q, is_event_active


class CoachServiceError(BaseServiceError):
    """Raised when a coach workflow fails validation."""


def get_user_profile(pk):
    """Return a user by PK."""
    try:
        return User.objects.get(pk=pk)
    except User.DoesNotExist:
        raise CoachServiceError("User not found", not_found=True)


def get_coach_rating(coach_pk):
    """Return a coach's rating profile."""
    coach = Coach.objects.filter(pk=coach_pk).first()
    if coach is None:
        # Distinguish between "no such user" and "user exists but isn't a coach"
        # for a slightly better error message. Both map to 404 at the view.
        if not User.objects.filter(pk=coach_pk).exists():
            raise CoachServiceError("User not found", not_found=True)
        raise CoachServiceError("User is not a coach", not_found=True)
    return coach


def get_all_coaches():
    """Return all users with is_coach=True."""
    return User.objects.filter(is_coach=True)


def get_feed_events(user):
    """Return active, unassigned events excluding those from organisers who blocked the user."""
    blocked_by = Organiser.objects.filter(
        blocked=user,
    ).values_list('user_id', flat=True)
    return Event.objects.filter(
        active_event_q(), coach_user__isnull=True,
    ).exclude(
        organiser_user_id__in=blocked_by,
    ).order_by('date')


def get_upcoming_jobs(user):
    """Return active events assigned to the given coach."""
    return Event.objects.filter(
        active_event_q(), coach_user=user,
    ).order_by('date')


def apply_to_event(user, event_pk):
    """Add the coach to the event's offers list."""
    with transaction.atomic():
        try:
            event = Event.objects.select_for_update().get(pk=event_pk)
        except Event.DoesNotExist:
            raise CoachServiceError("Event not found", not_found=True)
        if event.coach_user is not None:
            raise CoachServiceError("Event already has a coach assigned")
        if not is_event_active(event):
            raise CoachServiceError("Cannot apply to past events")
        blocked_by = Organiser.objects.filter(
            user=event.organiser_user, blocked=user,
        ).exists()
        if blocked_by:
            raise CoachServiceError("You are blocked by this organiser", forbidden=True)
        if event.offers.filter(pk=user.pk).exists():
            raise CoachServiceError("Already applied to this event")
        event.offers.add(user)
    notify_organiser_new_offer(event.organiser_user, user, event)
    return event


def unapply_from_event(user, event_pk):
    """Remove the coach from the event's offers list."""
    try:
        event = Event.objects.get(pk=event_pk)
    except Event.DoesNotExist:
        raise CoachServiceError("Event not found", not_found=True)
    event.offers.remove(user)
    return event


def cancel_assigned_event(user, event_pk):
    """Cancel the coach's assignment to an event."""
    try:
        event = Event.objects.get(pk=event_pk)
    except Event.DoesNotExist:
        raise CoachServiceError("Event not found", not_found=True)
    if event.coach_user != user:
        raise CoachServiceError("Not your assignment", forbidden=True)
    event.coach_user = None
    event.save()
    event.offers.remove(user)
    notify_organiser_coach_cancelled(event.organiser_user, event)
    return event
