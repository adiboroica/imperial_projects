from django.utils import timezone

from app.email import notify_favourites_of_new_event
from app.models import Event
from app.services._errors import BaseServiceError


class EventServiceError(BaseServiceError):
    """Raised when an event workflow fails validation."""


def get_organiser_events(user):
    """Return all events owned by the organiser, ordered by date."""
    return Event.objects.filter(organiser_user=user).order_by('date')


def create_event(user, validated_data):
    """Create an event from validated data and notify the organiser's favourites."""
    validated_data.pop('organiser_user_id', None)
    validated_data['organiser_user'] = user
    event = Event.objects.create(**validated_data)
    notify_favourites_of_new_event(user, event)
    return event


def fetch_event_for_update(user, event_pk):
    """Return an event after verifying ownership and temporal validity.

    Kept as a pure fetch + check because the import-linter contract forbids
    services from importing serializers. The view is responsible for running
    the serializer's field-level validation and calling ``.save()``.
    """
    try:
        event = Event.objects.get(pk=event_pk)
    except Event.DoesNotExist:
        raise EventServiceError("Event not found", not_found=True)
    if event.organiser_user != user:
        raise EventServiceError("Not your event", forbidden=True)
    if event.date < timezone.localdate():
        raise EventServiceError("Cannot edit past events")
    return event


# Backwards-compatible alias. Prefer ``fetch_event_for_update`` in new code.
validate_event_for_update = fetch_event_for_update


def delete_event(user, event_pk):
    """Delete an event after verifying ownership."""
    try:
        event = Event.objects.get(pk=event_pk)
    except Event.DoesNotExist:
        raise EventServiceError("Event not found", not_found=True)
    if event.organiser_user != user:
        raise EventServiceError("Not your event", forbidden=True)
    event.delete()


def get_event_offers(user, event_pk):
    """Return offer users with coach relation pre-fetched. Views handle serialization."""
    try:
        event = Event.objects.get(pk=event_pk)
    except Event.DoesNotExist:
        raise EventServiceError("Event not found", not_found=True)
    if event.organiser_user != user:
        raise EventServiceError("Not your event", forbidden=True)
    return event.offers.select_related('coach').all()


def get_event_organiser(event_pk):
    """Return the organiser user for a given event."""
    try:
        event = Event.objects.get(pk=event_pk)
    except Event.DoesNotExist:
        raise EventServiceError("Event not found", not_found=True)
    return event.organiser_user
