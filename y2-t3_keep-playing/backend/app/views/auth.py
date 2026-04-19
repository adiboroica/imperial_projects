from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import AnonRateThrottle, ScopedRateThrottle
from rest_framework.views import APIView

from app.authentication import LoginUsernameThrottle
from app.serializers import NewCoachUserSerializer, NewOrganiserUserSerializer


class HelloView(APIView):
    """Health-check endpoint that greets the authenticated user."""

    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        return Response("Hello {0}!".format(request.user))


class CreateCoachUser(APIView):
    """Public registration endpoint for new coach accounts."""

    authentication_classes = []
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'signup'

    def post(self, request, format=None):
        serializer = NewCoachUserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {"message": "Account created successfully"},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class CreateOrganiserUser(APIView):
    """Public registration endpoint for new organiser accounts."""

    authentication_classes = []
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'signup'

    def post(self, request, format=None):
        serializer = NewOrganiserUserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {"message": "Account created successfully"},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class ThrottledObtainAuthToken(ObtainAuthToken):
    """Login endpoint with per-IP and per-username rate-limiting."""

    throttle_classes = [AnonRateThrottle, LoginUsernameThrottle]


class LogoutView(APIView):
    """Delete the caller's auth token, invalidating the session server-side."""

    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        Token.objects.filter(user=request.user).delete()
        return Response({"message": "Logged out"})
