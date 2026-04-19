"""Email notifications for workflow events.

The public ``notify_*`` functions enqueue work onto django-q2 so request
handlers never block on SMTP. Workers pick up tasks and call the matching
``_send_*`` helper, which does the actual SMTP send with fail-silent logging.

Pass primary keys to the task (not model instances) because django-q2
serialises args via pickle and we want fresh DB reads at send time.
"""

import logging

from django.conf import settings
from django.core.mail import send_mail
from django_q.tasks import async_task

from app.models import Event, User

logger = logging.getLogger(__name__)

SENDER = getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@keep-playing.com')


def _safe_send_mail(subject, body, recipients):
    """Send an email, logging errors instead of crashing the worker."""
    try:
        send_mail(subject, body, SENDER, recipients, fail_silently=False)
    except Exception:
        logger.exception("Failed to send email to %s: %s", recipients, subject)


# -----------------------------------------------------------------------------
# Private SMTP senders (run on the django-q2 worker)
# -----------------------------------------------------------------------------

def _send_favourites_mail(organiser_user_pk: int, event_pk: int) -> None:
    organiser_user = User.objects.filter(pk=organiser_user_pk).first()
    event = Event.objects.filter(pk=event_pk).first()
    if organiser_user is None or event is None:
        logger.warning(
            "Favourites email skipped: missing organiser=%s or event=%s",
            organiser_user_pk, event_pk,
        )
        return
    # Cap at 500 to guard against pathological favourites lists.
    coaches = list(organiser_user.organiser.favourites.all()[:500])
    for coach in coaches:
        if not coach.email:
            continue
        _safe_send_mail(
            'New Job Offer',
            f'An organiser wants you to take a look at a potential opportunity.\n'
            f'{organiser_user.first_name} {organiser_user.last_name} would like to invite you to '
            f'apply for {event.name}, on {event.date}, at {event.location}.\n'
            f'To get more information or to apply for this opportunity open KeepPlaying.'
            f'\n\nBest,\nKeep Playing Team',
            [coach.email],
        )


def _send_coach_accepted_mail(coach_user_pk: int, event_pk: int) -> None:
    coach_user = User.objects.filter(pk=coach_user_pk).first()
    event = Event.objects.filter(pk=event_pk).first()
    if coach_user is None or event is None or not coach_user.email:
        return
    _safe_send_mail(
        'Your offer has been accepted!',
        f'You have been accepted for {event.name}, on {event.date}, at {event.location}. '
        f'Open Keep Playing for more details.'
        f'\n\nBest,\nKeep Playing Team',
        [coach_user.email],
    )


def _send_organiser_cancelled_mail(organiser_user_pk: int, event_pk: int) -> None:
    organiser_user = User.objects.filter(pk=organiser_user_pk).first()
    event = Event.objects.filter(pk=event_pk).first()
    if organiser_user is None or event is None or not organiser_user.email:
        return
    _safe_send_mail(
        f'A {event.role} has cancelled!',
        f'The {event.role} for {event.name}, on {event.date} has cancelled. '
        f'The position is now open again. Please check the app for updates. '
        f'Open Keep Playing for more details.'
        f'\n\nBest,\nKeep Playing Team',
        [organiser_user.email],
    )


def _send_organiser_new_offer_mail(organiser_user_pk: int, coach_user_pk: int, event_pk: int) -> None:
    organiser_user = User.objects.filter(pk=organiser_user_pk).first()
    coach_user = User.objects.filter(pk=coach_user_pk).first()
    event = Event.objects.filter(pk=event_pk).first()
    if organiser_user is None or coach_user is None or event is None or not organiser_user.email:
        return
    _safe_send_mail(
        f'Offer received for {event.name}, on {event.date}',
        f'You received a new offer from {coach_user.first_name} {coach_user.last_name}. '
        f'To get more information or to accept this offer open KeepPlaying.'
        f'\n\nBest,\nKeep Playing Team',
        [organiser_user.email],
    )


# -----------------------------------------------------------------------------
# Public enqueue wrappers (called from services)
# -----------------------------------------------------------------------------

def _enqueue(task_path: str, *args) -> None:
    """Enqueue a task, or log-and-return when notifications are disabled."""
    if not settings.EMAIL_NOTIFICATIONS_ENABLED:
        logger.info("Email disabled: would enqueue %s args=%s", task_path, args)
        return
    async_task(task_path, *args)


def notify_favourites_of_new_event(organiser_user, event):
    """Enqueue: notify favourite coaches about a new event."""
    _enqueue('app.email._send_favourites_mail', organiser_user.pk, event.pk)


def notify_coach_offer_accepted(coach_user, event):
    """Enqueue: notify a coach their offer has been accepted."""
    _enqueue('app.email._send_coach_accepted_mail', coach_user.pk, event.pk)


def notify_organiser_coach_cancelled(organiser_user, event):
    """Enqueue: notify an organiser that a coach has cancelled."""
    _enqueue('app.email._send_organiser_cancelled_mail', organiser_user.pk, event.pk)


def notify_organiser_new_offer(organiser_user, coach_user, event):
    """Enqueue: notify an organiser that a coach applied to their event."""
    _enqueue(
        'app.email._send_organiser_new_offer_mail',
        organiser_user.pk, coach_user.pk, event.pk,
    )
