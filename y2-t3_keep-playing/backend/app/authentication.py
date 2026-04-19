from datetime import timedelta

from django.conf import settings
from django.utils import timezone
from rest_framework.authentication import TokenAuthentication
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.throttling import SimpleRateThrottle


class ExpiringTokenAuthentication(TokenAuthentication):
    """Token authentication that rejects tokens older than TOKEN_EXPIRY_HOURS."""

    def authenticate_credentials(self, key):
        user, token = super().authenticate_credentials(key)
        expiry_hours = getattr(settings, 'TOKEN_EXPIRY_HOURS', 0)
        if expiry_hours and token.created < timezone.now() - timedelta(hours=expiry_hours):
            token.delete()
            raise AuthenticationFailed('Token has expired.')
        return user, token


class LoginUsernameThrottle(SimpleRateThrottle):
    """Throttles login attempts per-username (complements the per-IP AnonRateThrottle).

    Rate controlled by DEFAULT_THROTTLE_RATES['login_username'].
    """

    scope = 'login_username'

    def get_cache_key(self, request, view):
        username = (request.data.get('username') or '').strip().lower()
        if not username:
            return None  # no username → no per-user throttle
        return f'throttle_{self.scope}_{username}'
