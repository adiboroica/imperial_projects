from django.db.models import Q
from django.utils import timezone


def active_event_q():
    """Q filter for events whose next occurrence has not yet started.

    Recurring events are included on every day (not just their weekday)
    because a coach applies to the recurring *series*, not a single occurrence.
    """
    now = timezone.localtime()
    today = now.date()
    current_time = now.time()
    return (
        Q(recurring=False, date__gt=today)
        | Q(recurring=False, date=today, start_time__gt=current_time)
        | Q(recurring=True, recurring_end_date__isnull=True)
        | Q(recurring=True, recurring_end_date__gte=today)
    )


def is_event_active(event):
    """Instance-level check matching active_event_q."""
    now = timezone.localtime()
    today = now.date()
    if event.recurring:
        return event.recurring_end_date is None or event.recurring_end_date >= today
    if event.date > today:
        return True
    return event.date == today and event.start_time > now.time()


def is_event_concluded(event):
    """True once at least one occurrence of the event is over.

    Recurring events repeat weekly on the same weekday as ``event.date``.
    The function returns True as soon as any past occurrence's end time
    has passed, so the organiser can rate the coach promptly.
    """
    now = timezone.localtime()
    today = now.date()
    if event.recurring:
        if event.date > today:
            return False
        if event.recurring_end_date is not None and event.recurring_end_date < today:
            return True
        # At least one occurrence has happened if event.date < today.
        if event.date < today:
            if today.weekday() == event.date.weekday():
                # Today is the recurring day — concluded only after end_time.
                return event.end_time <= now.time()
            # Today is not the recurring day, so the last occurrence has ended.
            return True
        # event.date == today (first occurrence)
        return event.end_time <= now.time()
    if event.date < today:
        return True
    return event.date == today and event.end_time <= now.time()
