from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from app.serializers import PublicUserSerializer, UserSerializer
from app.services.coach import get_all_coaches


class UsersRecordView(APIView):
    """List all coach users."""

    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        users = get_all_coaches()
        serializer = PublicUserSerializer(users, many=True)
        return Response(serializer.data)


class UserRecordView(APIView):
    """Retrieve or update the authenticated user's profile.

    Registration is handled exclusively through ``/new_coach/`` and
    ``/new_organiser/`` — there is no generic create endpoint here.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        user = request.user
        serializer = UserSerializer(user, many=False)
        response = serializer.data
        response['pk'] = user.pk
        return Response(response)

    def patch(self, request):
        data = request.data.copy()
        for field in ('is_coach', 'is_organiser', 'verified', 'password'):
            data.pop(field, None)
        serializer = UserSerializer(request.user, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )
