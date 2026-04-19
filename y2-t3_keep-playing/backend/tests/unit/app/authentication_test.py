import pytest
from datetime import timedelta
from unittest.mock import patch

from django.utils import timezone
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import AuthenticationFailed

from app.authentication import ExpiringTokenAuthentication
from app.models import User


@pytest.mark.django_db
class ExpiringTokenAuthenticationTest:

    @pytest.fixture
    def user_and_token(self):
        user = User.objects.create_user(username='authuser', password='pass')
        token = Token.objects.create(user=user)
        return user, token

    @patch('app.authentication.settings')
    def test_fresh_token_accepted(self, mock_settings, user_and_token):
        mock_settings.TOKEN_EXPIRY_HOURS = 72
        user, token = user_and_token
        auth = ExpiringTokenAuthentication()
        result_user, result_token = auth.authenticate_credentials(token.key)
        assert result_user == user
        assert result_token == token

    @patch('app.authentication.settings')
    def test_expired_token_rejected(self, mock_settings, user_and_token):
        mock_settings.TOKEN_EXPIRY_HOURS = 72
        user, token = user_and_token
        token.created = timezone.now() - timedelta(hours=73)
        token.save()
        auth = ExpiringTokenAuthentication()
        with pytest.raises(AuthenticationFailed, match='expired'):
            auth.authenticate_credentials(token.key)
        assert not Token.objects.filter(key=token.key).exists()

    @patch('app.authentication.settings')
    def test_no_expiry_when_disabled(self, mock_settings, user_and_token):
        mock_settings.TOKEN_EXPIRY_HOURS = 0
        user, token = user_and_token
        token.created = timezone.now() - timedelta(days=365)
        token.save()
        auth = ExpiringTokenAuthentication()
        result_user, _ = auth.authenticate_credentials(token.key)
        assert result_user == user
