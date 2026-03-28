import pytest
from datetime import date, time, timedelta
from django.utils import timezone

from app.models import Event, Organiser, User


@pytest.mark.django_db
class EventCrudTest:

    def test_get_organiser_events(self, organiser_client, sample_event):
        response = organiser_client.get('/organiser/events/')
        assert response.status_code == 200
        assert len(response.data) == 1
        assert response.data[0]['name'] == 'Football Training'

    def test_create_event(self, organiser_client, organiser_user):
        now = timezone.now()
        future = date.today() + timedelta(days=30)
        response = organiser_client.post('/organiser/events/', {
            'name': 'New Event',
            'sport': 'Tennis',
            'role': 'Coach',
            'date': future.isoformat(),
            'location': 'Tennis Court',
            'details': 'A test event',
            'price': '60',
            'coach': 'False',
            'start_time': '14:00',
            'end_time': '16:00',
            'flexible_start_time': '13:30',
            'flexible_end_time': '16:30',
            'recurring': 'False',
            'creation_started': now.strftime('%Y-%m-%d %H:%M:%S'),
            'creation_ended': now.strftime('%Y-%m-%d %H:%M:%S'),
        }, format='json')
        assert response.status_code == 201
        assert Event.objects.filter(name='New Event').exists()

    def test_delete_event(self, organiser_client, sample_event):
        response = organiser_client.delete(f'/organiser/events/{sample_event.pk}/')
        assert response.status_code == 200
        assert not Event.objects.filter(pk=sample_event.pk).exists()

    def test_patch_event(self, organiser_client, sample_event):
        response = organiser_client.patch(
            f'/organiser/events/{sample_event.pk}/',
            {'name': 'Updated Training'},
            format='json',
        )
        assert response.status_code == 202
        sample_event.refresh_from_db()
        assert sample_event.name == 'Updated Training'

    def test_delete_event_not_found(self, organiser_client):
        response = organiser_client.delete('/organiser/events/99999/')
        assert response.status_code == 404

    def test_get_event_organiser(self, coach_client, sample_event, organiser_user):
        response = coach_client.get(f'/event/{sample_event.pk}/organiser/')
        assert response.status_code == 200
        assert response.data['username'] == organiser_user.username


@pytest.mark.django_db
class EventPermissionsTest:

    def test_coach_cannot_create_event(self, coach_client):
        response = coach_client.post('/organiser/events/', {
            'name': 'Blocked',
        })
        assert response.status_code == 403

    def test_coach_cannot_delete_event(self, coach_client, sample_event):
        response = coach_client.delete(f'/organiser/events/{sample_event.pk}/')
        assert response.status_code == 403

    def test_unauthenticated_cannot_access_events(self, api_client):
        response = api_client.get('/organiser/events/')
        assert response.status_code == 401

    def test_other_organiser_cannot_delete(self, sample_event):
        from rest_framework.authtoken.models import Token
        from rest_framework.test import APIClient
        other = User.objects.create_user(
            username='other_org', password='pass', is_organiser=True,
        )
        Organiser.objects.create(user=other)
        token = Token.objects.create(user=other)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        response = client.delete(f'/organiser/events/{sample_event.pk}/')
        assert response.status_code == 403
