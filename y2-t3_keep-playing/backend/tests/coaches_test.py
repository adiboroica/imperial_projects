import pytest
from datetime import date, time, timedelta, datetime

from app.models import Event, Organiser, User


@pytest.mark.django_db
class CoachFeedTest:

    def test_feed_shows_unassigned_future_events(self, coach_client, sample_event):
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        names = [e['name'] for e in response.data]
        assert 'Football Training' in names

    def test_feed_excludes_assigned_events(self, coach_client, assigned_event):
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        names = [e['name'] for e in response.data]
        assert 'Swimming Lessons' not in names

    def test_feed_excludes_blocked_organiser(self, coach_client, coach_user, sample_event, organiser_user):
        organiser_user.organiser.blocked.add(coach_user)
        response = coach_client.get('/coach/feed/')
        assert response.status_code == 200
        assert len(response.data) == 0


@pytest.mark.django_db
class CoachApplyTest:

    def test_apply_to_event(self, coach_client, coach_user, sample_event):
        response = coach_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert coach_user in sample_event.offers.all()

    def test_unapply_from_event(self, coach_client, coach_user, sample_event):
        sample_event.offers.add(coach_user)
        response = coach_client.patch(f'/coach/events/{sample_event.pk}/unapply/')
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert coach_user not in sample_event.offers.all()

    def test_cancel_assigned_job(self, coach_client, coach_user, assigned_event):
        response = coach_client.patch(f'/coach/events/{assigned_event.pk}/cancel/')
        assert response.status_code == 202
        assigned_event.refresh_from_db()
        assert assigned_event.coach_user is None
        assert assigned_event.coach is False

    def test_cancel_ignores_malicious_request_body(self, coach_client, coach_user, assigned_event):
        """A coach sending {'coach': true} in the cancel body should not override the cancellation."""
        response = coach_client.patch(
            f'/coach/events/{assigned_event.pk}/cancel/',
            {'coach': True},
            format='json',
        )
        assert response.status_code == 202
        assigned_event.refresh_from_db()
        assert assigned_event.coach is False
        assert assigned_event.coach_user is None


@pytest.mark.django_db
class CoachUpcomingJobsTest:

    def test_upcoming_jobs(self, coach_client, assigned_event):
        response = coach_client.get('/coach/upcoming-jobs/')
        assert response.status_code == 200
        assert len(response.data) == 1
        assert response.data[0]['name'] == 'Swimming Lessons'

    def test_upcoming_jobs_excludes_other_coaches(self, coach_client, sample_event):
        response = coach_client.get('/coach/upcoming-jobs/')
        assert response.status_code == 200
        assert len(response.data) == 0


@pytest.mark.django_db
class CoachPermissionsTest:

    def test_organiser_cannot_access_feed(self, organiser_client):
        response = organiser_client.get('/coach/feed/')
        assert response.status_code == 403

    def test_organiser_cannot_apply(self, organiser_client, sample_event):
        response = organiser_client.patch(f'/coach/events/{sample_event.pk}/apply/')
        assert response.status_code == 403
