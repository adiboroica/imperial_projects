from rest_framework import status
from rest_framework.response import Response

from app.services._errors import BaseServiceError


def error_response(e: BaseServiceError) -> Response:
    """Map any ``BaseServiceError`` to the right HTTP status code."""
    if e.not_found:
        code = status.HTTP_404_NOT_FOUND
    elif e.forbidden:
        code = status.HTTP_403_FORBIDDEN
    else:
        code = status.HTTP_400_BAD_REQUEST
    return Response({"error": True, "error_msg": e.message}, status=code)
