import pytest
from datetime import date, time, timedelta

from django.utils import timezone
from rest_framework.test import APIRequestFactory, force_authenticate

from app.models import Event, Organiser, User
from app.views.events import EventView


@pytest.mark.django_db
class EventPatchFieldStrippingTest:
    """EventView.patch strips workflow fields from request data."""

    @pytest.fixture
    def org_user(self):
        user = User.objects.create_user(username='org', password='pass', is_organiser=True)
        Organiser.objects.create(user=user)
        return user

    @pytest.fixture
    def event(self, org_user):
        now = timezone.now()
        return Event.objects.create(
            name='Original',
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

    def test_strips_workflow_fields(self, org_user, event):
        coach = User.objects.create_user(username='coach', password='pass', is_coach=True)
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/events/{event.pk}/',
            {
                'name': 'Updated',
                'coach_user': coach.pk,
                'voted': True,
                'coach': True,
            },
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = EventView.as_view()(request, pk=event.pk)
        assert response.status_code == 202
        event.refresh_from_db()
        assert event.name == 'Updated'
        assert event.coach_user is None
        assert event.voted is False

    def test_rejects_past_event_edit(self, org_user):
        now = timezone.now()
        past_event = Event.objects.create(
            name='Past',
            sport='Football',
            role='Coach',
            date=date.today() - timedelta(days=1),
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
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/events/{past_event.pk}/',
            {'name': 'Edited'},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = EventView.as_view()(request, pk=past_event.pk)
        assert response.status_code == 400
        assert 'past' in response.data['error_msg'].lower()


@pytest.mark.django_db
class EventDeleteOwnershipTest:

    def test_only_owner_can_delete(self):
        org1 = User.objects.create_user(username='org1', password='pass', is_organiser=True)
        Organiser.objects.create(user=org1)
        org2 = User.objects.create_user(username='org2', password='pass', is_organiser=True)
        Organiser.objects.create(user=org2)

        now = timezone.now()
        event = Event.objects.create(
            name='Owned',
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
            organiser_user=org1,
            creation_started=now,
            creation_ended=now,
        )

        factory = APIRequestFactory()
        request = factory.delete(f'/organiser/events/{event.pk}/')
        force_authenticate(request, user=org2)
        response = EventView.as_view()(request, pk=event.pk)
        assert response.status_code == 403
        assert Event.objects.filter(pk=event.pk).exists()
