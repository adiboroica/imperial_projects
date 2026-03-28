import pytest
from unittest.mock import patch, call

from app.email import (
    notify_favourites_of_new_event,
    notify_coach_offer_accepted,
    notify_organiser_coach_cancelled,
    notify_organiser_new_offer,
    SENDER,
)
from app.models import Coach, Event, Organiser, User
from datetime import date, time
from django.utils import timezone


@pytest.fixture
def org_user(db):
    user = User.objects.create_user(
        username='org_email',
        password='pass',
        first_name='Alice',
        last_name='Smith',
        email='alice@test.com',
        is_organiser=True,
    )
    Organiser.objects.create(user=user)
    return user


@pytest.fixture
def coach_user_a(db):
    user = User.objects.create_user(
        username='coach_a',
        password='pass',
        first_name='Bob',
        last_name='Jones',
        email='bob@test.com',
        is_coach=True,
    )
    Coach.objects.create(user=user)
    return user


@pytest.fixture
def coach_user_b(db):
    user = User.objects.create_user(
        username='coach_b',
        password='pass',
        first_name='Charlie',
        last_name='Brown',
        email='charlie@test.com',
        is_coach=True,
    )
    Coach.objects.create(user=user)
    return user


@pytest.fixture
def event(org_user):
    now = timezone.now()
    return Event.objects.create(
        name='Test Match',
        sport='Football',
        role='Referee',
        date=date(2030, 6, 15),
        location='Wembley',
        details='Cup final',
        price=100,
        coach=False,
        start_time=time(15, 0),
        end_time=time(17, 0),
        flexible_start_time=time(14, 30),
        flexible_end_time=time(17, 30),
        organiser_user=org_user,
        creation_started=now,
        creation_ended=now,
    )


@pytest.mark.django_db
class EmailDisabledTest:
    """When EMAIL_NOTIFICATIONS_ENABLED=False, no emails are sent."""

    @patch('app.email.send_mail')
    def test_notify_favourites_does_not_send(self, mock_send, org_user, coach_user_a, event):
        org_user.organiser.favourites.add(coach_user_a)
        notify_favourites_of_new_event(org_user, event)
        mock_send.assert_not_called()

    @patch('app.email.send_mail')
    def test_notify_coach_accepted_does_not_send(self, mock_send, coach_user_a, event):
        notify_coach_offer_accepted(coach_user_a, event)
        mock_send.assert_not_called()

    @patch('app.email.send_mail')
    def test_notify_organiser_cancelled_does_not_send(self, mock_send, org_user, event):
        notify_organiser_coach_cancelled(org_user, event)
        mock_send.assert_not_called()

    @patch('app.email.send_mail')
    def test_notify_organiser_new_offer_does_not_send(self, mock_send, org_user, coach_user_a, event):
        notify_organiser_new_offer(org_user, coach_user_a, event)
        mock_send.assert_not_called()


@pytest.mark.django_db
class EmailEnabledTest:
    """When EMAIL_NOTIFICATIONS_ENABLED=True, emails are sent."""

    @patch('app.email.settings')
    @patch('app.email.send_mail')
    def test_notify_favourites_sends_to_each(self, mock_send, mock_settings, org_user, coach_user_a, coach_user_b, event):
        mock_settings.EMAIL_NOTIFICATIONS_ENABLED = True
        org_user.organiser.favourites.add(coach_user_a, coach_user_b)

        notify_favourites_of_new_event(org_user, event)

        assert mock_send.call_count == 2
        recipients = {c.args[3][0] for c in mock_send.call_args_list}
        assert recipients == {'bob@test.com', 'charlie@test.com'}

    @patch('app.email.settings')
    @patch('app.email.send_mail')
    def test_notify_favourites_no_favourites_sends_nothing(self, mock_send, mock_settings, org_user, event):
        mock_settings.EMAIL_NOTIFICATIONS_ENABLED = True
        notify_favourites_of_new_event(org_user, event)
        mock_send.assert_not_called()

    @patch('app.email.settings')
    @patch('app.email.send_mail')
    def test_notify_coach_accepted_sends(self, mock_send, mock_settings, coach_user_a, event):
        mock_settings.EMAIL_NOTIFICATIONS_ENABLED = True
        notify_coach_offer_accepted(coach_user_a, event)

        mock_send.assert_called_once()
        args = mock_send.call_args
        assert args[0][0] == 'Your offer has been accepted!'
        assert args[0][3] == ['bob@test.com']
        assert args[0][2] == SENDER
        assert event.name in args[0][1]

    @patch('app.email.settings')
    @patch('app.email.send_mail')
    def test_notify_organiser_cancelled_sends(self, mock_send, mock_settings, org_user, event):
        mock_settings.EMAIL_NOTIFICATIONS_ENABLED = True
        notify_organiser_coach_cancelled(org_user, event)

        mock_send.assert_called_once()
        args = mock_send.call_args
        assert event.role in args[0][0]
        assert args[0][3] == ['alice@test.com']

    @patch('app.email.settings')
    @patch('app.email.send_mail')
    def test_notify_organiser_new_offer_sends(self, mock_send, mock_settings, org_user, coach_user_a, event):
        mock_settings.EMAIL_NOTIFICATIONS_ENABLED = True
        notify_organiser_new_offer(org_user, coach_user_a, event)

        mock_send.assert_called_once()
        args = mock_send.call_args
        assert event.name in args[0][0]
        assert args[0][3] == ['alice@test.com']
        assert 'Bob Jones' in args[0][1]
