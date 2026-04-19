import pytest

from app.models import Coach, Organiser, User
from app.serializers import OrganiserSerializer


@pytest.mark.django_db
class OrganiserSerializerTest:

    @pytest.fixture
    def organiser(self):
        user = User.objects.create_user(username='org', password='pass', is_organiser=True)
        return Organiser.objects.create(user=user)

    @pytest.fixture
    def coach_user(self):
        user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        Coach.objects.create(user=user)
        return user

    def test_update_defaults(self, organiser):
        serializer = OrganiserSerializer(
            organiser,
            data={
                'default_sport': 'Tennis',
                'default_role': 'Referee',
                'default_price': 100,
                'default_location': 'Wimbledon',
                'favourites_ids': [],
                'blocked_ids': [],
            },
            partial=True,
        )
        assert serializer.is_valid(), serializer.errors
        serializer.save()
        organiser.refresh_from_db()
        assert organiser.default_sport == 'Tennis'
        assert organiser.default_role == 'Referee'
        assert organiser.default_price == 100
        assert organiser.default_location == 'Wimbledon'

    def test_update_favourites(self, organiser, coach_user):
        serializer = OrganiserSerializer(
            organiser,
            data={'favourites_ids': [coach_user.pk], 'blocked_ids': []},
            partial=True,
        )
        assert serializer.is_valid(), serializer.errors
        serializer.save()
        assert coach_user in organiser.favourites.all()

    def test_update_blocked(self, organiser, coach_user):
        serializer = OrganiserSerializer(
            organiser,
            data={'blocked_ids': [coach_user.pk], 'favourites_ids': []},
            partial=True,
        )
        assert serializer.is_valid(), serializer.errors
        serializer.save()
        assert coach_user in organiser.blocked.all()

    def test_write_only_fields(self, organiser):
        data = OrganiserSerializer(organiser).data
        assert 'favourites_ids' not in data
        assert 'blocked_ids' not in data
        assert 'favourites' in data
        assert 'blocked' in data
