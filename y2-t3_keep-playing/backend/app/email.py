import logging

from django.conf import settings
from django.core.mail import send_mail

logger = logging.getLogger(__name__)

SENDER = 'drp@keep_playing.com'


def notify_favourites_of_new_event(organiser_user, event):
    """Notify favourite coaches about a new event from an organiser."""
    coaches = organiser_user.organiser.favourites.all()
    if not settings.EMAIL_NOTIFICATIONS_ENABLED:
        logger.info(
            "Email disabled: Would notify %d favourites about event '%s'",
            coaches.count(), event.name,
        )
        return
    for coach in coaches:
        send_mail(
            'New Job Offer',
            f'An organiser wants you to take a look at a potential opportunity.\n'
            f'{organiser_user.first_name} {organiser_user.last_name} would like to invite you to '
            f'apply for {event.name}, on {event.date}, at {event.location}.\n'
            f'To get more information or to apply for this opportunity open KeepPlaying.'
            f'\n\nBest,\nKeep Playing Team',
            SENDER,
            [coach.email],
            fail_silently=False,
        )


def notify_coach_offer_accepted(coach_user, event):
    """Notify a coach that their offer has been accepted."""
    if not settings.EMAIL_NOTIFICATIONS_ENABLED:
        logger.info(
            "Email disabled: Would notify %s about acceptance for '%s'",
            coach_user.username, event.name,
        )
        return
    send_mail(
        'Your offer has been accepted!',
        f'You have been accepted for {event.name}, on {event.date}, at {event.location}. '
        f'Open Keep Playing for more details.'
        f'\n\nBest,\nKeep Playing Team',
        SENDER,
        [coach_user.email],
        fail_silently=False,
    )


def notify_organiser_coach_cancelled(organiser_user, event):
    """Notify an organiser that a coach has cancelled."""
    if not settings.EMAIL_NOTIFICATIONS_ENABLED:
        logger.info(
            "Email disabled: Would notify %s about cancellation for '%s'",
            organiser_user.username, event.name,
        )
        return
    send_mail(
        f'A {event.role} has cancelled!',
        f'The {event.role} for {event.name}, on {event.date} has cancelled. '
        f"Don't worry! We have already triggered another search. "
        f'Open Keep Playing for more details.'
        f'\n\nBest,\nKeep Playing Team',
        SENDER,
        [organiser_user.email],
        fail_silently=False,
    )


def notify_organiser_new_offer(organiser_user, coach_user, event):
    """Notify an organiser that a coach has applied to their event."""
    if not settings.EMAIL_NOTIFICATIONS_ENABLED:
        logger.info(
            "Email disabled: Would notify %s about offer from %s for '%s'",
            organiser_user.username, coach_user.username, event.name,
        )
        return
    send_mail(
        f'Offer received for {event.name}, on {event.date}',
        f'You received a new offer from {coach_user.first_name} {coach_user.last_name}. '
        f'To get more information or to accept this offer open KeepPlaying.'
        f'\n\nBest,\nKeep Playing Team',
        SENDER,
        [organiser_user.email],
        fail_silently=False,
    )
