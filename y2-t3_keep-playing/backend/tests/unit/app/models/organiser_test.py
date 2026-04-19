import pytest

from app.models import Organiser, User


@pytest.mark.django_db
class OrganiserModelTest:

    def test_create_organiser(self):
        user = User.objects.create_user(username='org', password='pass', is_organiser=True)
        organiser = Organiser.objects.create(user=user)
        assert str(organiser) == 'Organiser: org'
        assert organiser.user == user

    def test_default_fields(self):
        user = User.objects.create_user(username='org2', password='pass', is_organiser=True)
        organiser = Organiser.objects.create(user=user)
        assert organiser.default_location == ''
        assert organiser.default_price is None
        assert organiser.default_sport == ''
        assert organiser.default_role == ''

    def test_favourites_m2m(self):
        org_user = User.objects.create_user(username='org3', password='pass', is_organiser=True)
        coach_user = User.objects.create_user(username='coach1', password='pass', is_coach=True)
        organiser = Organiser.objects.create(user=org_user)

        organiser.favourites.add(coach_user)
        assert coach_user in organiser.favourites.all()

        organiser.favourites.remove(coach_user)
        assert coach_user not in organiser.favourites.all()

    def test_blocked_m2m(self):
        org_user = User.objects.create_user(username='org4', password='pass', is_organiser=True)
        coach_user = User.objects.create_user(username='coach2', password='pass', is_coach=True)
        organiser = Organiser.objects.create(user=org_user)

        organiser.blocked.add(coach_user)
        assert coach_user in organiser.blocked.all()

        organiser.blocked.remove(coach_user)
        assert coach_user not in organiser.blocked.all()

    def test_cascade_delete(self):
        user = User.objects.create_user(username='org5', password='pass', is_organiser=True)
        Organiser.objects.create(user=user)
        user.delete()
        assert not Organiser.objects.filter(pk=user.pk).exists()
