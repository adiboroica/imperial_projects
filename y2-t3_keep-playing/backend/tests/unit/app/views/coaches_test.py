import pytest
from datetime import date, time, timedelta

from django.utils import timezone
from rest_framework.test import APIRequestFactory, force_authenticate

from app.models import Coach, Event, Organiser, User
from app.views.coaches import CoachEventView


@pytest.mark.django_db
class CoachApplyViewTest:
    """Tests that the view correctly delegates to the service and maps errors to HTTP status codes."""

    @pytest.fixture
    def org_user(self):
        user = User.objects.create_user(username='org3', password='pass', is_organiser=True)
        Organiser.objects.create(user=user)
        return user

    @pytest.fixture
    def coach_user(self):
        user = User.objects.create_user(username='coach3', password='pass', is_coach=True)
        Coach.objects.create(user=user)
        return user

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

    def test_apply_to_assigned_event_returns_400(self, org_user, coach_user):
        other_coach = User.objects.create_user(username='other', password='pass', is_coach=True)
        event = self._make_event(org_user, coach_user=other_coach)

        factory = APIRequestFactory()
        request = factory.patch(f'/coach/events/{event.pk}/apply/')
        force_authenticate(request, user=coach_user)
        response = CoachEventView.as_view()(request, pk=event.pk)
        assert response.status_code == 400
        assert 'already has a coach' in response.data['error_msg']

    def test_apply_to_past_event_returns_400(self, org_user, coach_user):
        event = self._make_event(org_user, date=date.today() - timedelta(days=1))

        factory = APIRequestFactory()
        request = factory.patch(f'/coach/events/{event.pk}/apply/')
        force_authenticate(request, user=coach_user)
        response = CoachEventView.as_view()(request, pk=event.pk)
        assert response.status_code == 400
        assert 'past' in response.data['error_msg'].lower()

    def test_blocked_coach_returns_403(self, org_user, coach_user):
        org_user.organiser.blocked.add(coach_user)
        event = self._make_event(org_user)

        factory = APIRequestFactory()
        request = factory.patch(f'/coach/events/{event.pk}/apply/')
        force_authenticate(request, user=coach_user)
        response = CoachEventView.as_view()(request, pk=event.pk)
        assert response.status_code == 403
        assert 'blocked' in response.data['error_msg']
