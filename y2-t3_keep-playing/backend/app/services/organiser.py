from django.db import transaction

from app.email import notify_coach_offer_accepted
from app.models import Coach, Event, User
from app.services._errors import BaseServiceError
from app.services.temporal import is_event_concluded


class OrganiserServiceError(BaseServiceError):
    """Raised when an organiser workflow fails validation."""


def accept_offer(user, event_pk, coach_pk):
    """Accept a coach's offer for an event."""
    try:
        coach_user = User.objects.get(pk=coach_pk)
    except User.DoesNotExist:
        raise OrganiserServiceError("Coach not found", not_found=True)
    if not coach_user.is_coach:
        raise OrganiserServiceError("User is not a coach")
    with transaction.atomic():
        try:
            event = Event.objects.select_for_update().get(pk=event_pk)
        except Event.DoesNotExist:
            raise OrganiserServiceError("Event not found", not_found=True)
        if event.organiser_user != user:
            raise OrganiserServiceError("Not your event", forbidden=True)
        if event.coach_user is not None:
            raise OrganiserServiceError("Event already has a coach assigned")
        if not event.offers.filter(pk=coach_pk).exists():
            raise OrganiserServiceError("Coach has not applied to this event")
        event.coach_user = coach_user
        event.save()
        event.offers.clear()
    notify_coach_offer_accepted(coach_user, event)
    return event


def _get_coach_user(coach_pk):
    """Look up a coach user by PK, raising OrganiserServiceError if not found."""
    try:
        user = User.objects.get(pk=coach_pk, is_coach=True)
    except User.DoesNotExist:
        raise OrganiserServiceError("Coach not found", not_found=True)
    return user


def block_coach(user, coach_pk):
    """Add a coach to the organiser's blocked list (removes from favourites)."""
    _get_coach_user(coach_pk)
    organiser = user.organiser
    with transaction.atomic():
        organiser.favourites.remove(coach_pk)
        organiser.blocked.add(coach_pk)
    return organiser


def unblock_coach(user, coach_pk):
    """Remove a coach from the organiser's blocked list."""
    _get_coach_user(coach_pk)
    organiser = user.organiser
    organiser.blocked.remove(coach_pk)
    return organiser


def add_favourite(user, coach_pk):
    """Add a coach to the organiser's favourites (removes from blocked)."""
    _get_coach_user(coach_pk)
    organiser = user.organiser
    with transaction.atomic():
        organiser.blocked.remove(coach_pk)
        organiser.favourites.add(coach_pk)
    return organiser


def remove_favourite(user, coach_pk):
    """Remove a coach from the organiser's favourites."""
    _get_coach_user(coach_pk)
    organiser = user.organiser
    organiser.favourites.remove(coach_pk)
    return organiser


def vote_coach(user, event_pk, experience, flexibility, reliability):
    """Rate a coach for a past event. Scores must be integers between 1 and 5."""
    for name, value in [('experience', experience), ('flexibility', flexibility), ('reliability', reliability)]:
        # Reject bool explicitly: isinstance(True, int) is True in Python.
        if isinstance(value, bool) or not isinstance(value, int):
            raise OrganiserServiceError(f"{name} must be an integer")
        if not 1 <= value <= 5:
            raise OrganiserServiceError("Scores must be between 1 and 5")
    with transaction.atomic():
        try:
            event = Event.objects.select_for_update().get(pk=event_pk)
        except Event.DoesNotExist:
            raise OrganiserServiceError("Event not found", not_found=True)
        if event.organiser_user != user:
            raise OrganiserServiceError("Not your event", forbidden=True)
        if event.coach_user is None:
            raise OrganiserServiceError("Event has no assigned coach")
        if not is_event_concluded(event):
            raise OrganiserServiceError("Event has not happened yet")
        if event.voted:
            raise OrganiserServiceError("This event has already been rated")
        coach = Coach.objects.select_for_update().get(pk=event.coach_user.pk)
        event.voted = True
        event.save()
        coach.votes += 1
        coach.experience += experience
        coach.flexibility += flexibility
        coach.reliability += reliability
        coach.save()
    return coach
