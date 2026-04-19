import pytest
from datetime import date, time, timedelta

from django.utils import timezone
from rest_framework.test import APIRequestFactory, force_authenticate

from app.models import Coach, Event, Organiser, User
from app.views.organisers import AcceptOfferView, VoteCoachView


@pytest.mark.django_db
class AcceptOfferValidationTest:

    @pytest.fixture
    def org_user(self):
        user = User.objects.create_user(username='org', password='pass', is_organiser=True)
        Organiser.objects.create(user=user)
        return user

    @pytest.fixture
    def coach_user(self):
        user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        Coach.objects.create(user=user)
        return user

    @pytest.fixture
    def event(self, org_user):
        now = timezone.now()
        return Event.objects.create(
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

    def test_rejects_non_coach_user(self, org_user, event):
        non_coach = User.objects.create_user(username='regular', password='pass')
        event.offers.add(non_coach)
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/events/{event.pk}/accept/{non_coach.pk}/',
            {'coach': True},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = AcceptOfferView.as_view()(request, pk=event.pk, coach_pk=non_coach.pk)
        assert response.status_code == 400
        assert 'not a coach' in response.data['error_msg']

    def test_rejects_coach_not_in_offers(self, org_user, coach_user, event):
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/events/{event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = AcceptOfferView.as_view()(request, pk=event.pk, coach_pk=coach_user.pk)
        assert response.status_code == 400
        assert 'not applied' in response.data['error_msg']

    def test_only_owner_can_accept(self, org_user, coach_user, event):
        event.offers.add(coach_user)
        other_org = User.objects.create_user(username='other', password='pass', is_organiser=True)
        Organiser.objects.create(user=other_org)

        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/events/{event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        force_authenticate(request, user=other_org)
        response = AcceptOfferView.as_view()(request, pk=event.pk, coach_pk=coach_user.pk)
        assert response.status_code == 403

    def test_clears_offers_after_acceptance(self, org_user, coach_user, event):
        other_coach = User.objects.create_user(username='other_c', password='pass', is_coach=True)
        Coach.objects.create(user=other_coach)
        event.offers.add(coach_user, other_coach)

        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/events/{event.pk}/accept/{coach_user.pk}/',
            {'coach': True},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = AcceptOfferView.as_view()(request, pk=event.pk, coach_pk=coach_user.pk)
        assert response.status_code == 202
        event.refresh_from_db()
        assert event.coach_user == coach_user
        assert event.offers.count() == 0


@pytest.mark.django_db
class VoteCoachValidationTest:

    @pytest.fixture
    def org_user(self):
        user = User.objects.create_user(username='org_v', password='pass', is_organiser=True)
        Organiser.objects.create(user=user)
        return user

    @pytest.fixture
    def coach_user(self):
        user = User.objects.create_user(username='coach_v', password='pass', is_coach=True)
        Coach.objects.create(user=user)
        return user

    @pytest.fixture
    def past_event(self, org_user, coach_user):
        now = timezone.now()
        return Event.objects.create(
            name='Past Event',
            sport='Football',
            role='Coach',
            date=date.today() - timedelta(days=7),
            location='London',
            details='Details',
            price=50,
            coach_user=coach_user,
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 30),
            flexible_end_time=time(12, 30),
            organiser_user=org_user,
            creation_started=now,
            creation_ended=now,
        )

    def test_rejects_missing_fields(self, org_user, past_event):
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/vote/{past_event.pk}/',
            {'experience': 5},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = VoteCoachView.as_view()(request, event_pk=past_event.pk)
        assert response.status_code == 400

    def test_rejects_non_integer_scores(self, org_user, past_event):
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/vote/{past_event.pk}/',
            {'experience': 'great', 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = VoteCoachView.as_view()(request, event_pk=past_event.pk)
        assert response.status_code == 400

    def test_rejects_out_of_range_scores(self, org_user, past_event):
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/vote/{past_event.pk}/',
            {'experience': 6, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = VoteCoachView.as_view()(request, event_pk=past_event.pk)
        assert response.status_code == 400
        assert '1 and 5' in response.data['error_msg']

    def test_rejects_vote_on_future_event(self, org_user, coach_user):
        now = timezone.now()
        future = Event.objects.create(
            name='Future',
            sport='Football',
            role='Coach',
            date=date.today() + timedelta(days=7),
            location='London',
            details='Details',
            price=50,
            coach_user=coach_user,
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
            f'/organiser/vote/{future.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = VoteCoachView.as_view()(request, event_pk=future.pk)
        assert response.status_code == 400
        assert 'not happened yet' in response.data['error_msg']

    def test_rejects_double_vote(self, org_user, past_event):
        past_event.voted = True
        past_event.save()
        factory = APIRequestFactory()
        request = factory.patch(
            f'/organiser/vote/{past_event.pk}/',
            {'experience': 5, 'flexibility': 4, 'reliability': 5},
            format='json',
        )
        force_authenticate(request, user=org_user)
        response = VoteCoachView.as_view()(request, event_pk=past_event.pk)
        assert response.status_code == 400
        assert 'already been rated' in response.data['error_msg']
