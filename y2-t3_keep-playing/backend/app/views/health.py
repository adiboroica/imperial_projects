from django.db import connection
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


class HealthView(APIView):
    """Liveness + DB check for orchestrator probes."""

    authentication_classes = []
    permission_classes = [AllowAny]
    throttle_classes = []

    def get(self, request, format=None):
        try:
            connection.ensure_connection()
            db_status = 'ok'
        except Exception:
            db_status = 'fail'
        payload = {'status': 'ok' if db_status == 'ok' else 'degraded', 'db': db_status}
        return Response(payload, status=200 if db_status == 'ok' else 503)
