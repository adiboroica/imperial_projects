import pytest

from app.models import Coach, User


@pytest.mark.django_db
class CoachModelTest:

    def test_create_coach(self):
        user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        coach = Coach.objects.create(user=user)
        assert str(coach) == 'Coach: coach'
        assert coach.user == user

    def test_rating_defaults(self):
        user = User.objects.create_user(username='coach2', password='pass', is_coach=True)
        coach = Coach.objects.create(user=user)
        assert coach.votes == 0
        assert coach.experience == 0
        assert coach.flexibility == 0
        assert coach.reliability == 0

    def test_rating_increment(self):
        user = User.objects.create_user(username='coach3', password='pass', is_coach=True)
        coach = Coach.objects.create(user=user)
        coach.votes += 1
        coach.experience += 5
        coach.flexibility += 4
        coach.reliability += 3
        coach.save()
        coach.refresh_from_db()
        assert coach.votes == 1
        assert coach.experience == 5
        assert coach.flexibility == 4
        assert coach.reliability == 3

    def test_cascade_delete(self):
        user = User.objects.create_user(username='coach4', password='pass', is_coach=True)
        Coach.objects.create(user=user)
        user.delete()
        assert not Coach.objects.filter(pk=user.pk).exists()
