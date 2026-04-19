import pytest

from app.models import Coach, User
from app.serializers import CoachSerializer


@pytest.mark.django_db
class CoachSerializerTest:

    def test_fields(self):
        user = User.objects.create_user(username='coach', password='pass', is_coach=True)
        coach = Coach.objects.create(user=user)
        data = CoachSerializer(coach).data
        assert set(data.keys()) == {'pk', 'user', 'votes', 'experience', 'flexibility', 'reliability'}

    def test_serializes_correctly(self):
        user = User.objects.create_user(username='coach2', password='pass', is_coach=True)
        coach = Coach.objects.create(user=user, votes=3, experience=12, flexibility=9, reliability=15)
        data = CoachSerializer(coach).data
        assert data['votes'] == 3
        assert data['experience'] == 12
        assert data['flexibility'] == 9
        assert data['reliability'] == 15
        assert data['user'] == user.pk
