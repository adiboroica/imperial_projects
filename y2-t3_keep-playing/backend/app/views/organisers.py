from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from ..email import notify_coach_offer_accepted
from ..models import Event, User
from ..permissions import IsOrganiser
from ..serializers import EventSerializer, OrganiserSerializer


class OrganiserView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def get(self, request, format=None):
        serializer = OrganiserSerializer(request.user.organiser, many=False)
        return Response(serializer.data)

    def patch(self, request, format=None):
        organiser = request.user.organiser
        serializer = OrganiserSerializer(organiser, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_202_ACCEPTED)
        return Response(
            {"error": True, "error_msg": "Organiser does not exist"},
            status=status.HTTP_400_BAD_REQUEST,
        )


class AcceptOfferView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, pk, coach_pk, format=None):
        event = get_object_or_404(Event, pk=pk)
        if event.organiser_user != request.user:
            return Response(
                {"error": True, "error_msg": "Not your event"},
                status=status.HTTP_403_FORBIDDEN,
            )
        coach_user = get_object_or_404(User, pk=coach_pk)
        serializer = EventSerializer(event, data=request.data, partial=True)
        event.coach_user = coach_user
        notify_coach_offer_accepted(coach_user, event)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_202_ACCEPTED)
        return Response(
            {"error": True, "error_msg": "Event does not exist"},
            status=status.HTTP_400_BAD_REQUEST,
        )


class OrganiserBlockCoachView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        organiser = request.user.organiser
        organiser.blocked.add(coach_pk)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserUnblockCoachView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        organiser = request.user.organiser
        organiser.blocked.remove(coach_pk)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserAddFavouriteCoachView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        organiser = request.user.organiser
        organiser.favourites.add(coach_pk)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserRemoveFavouriteCoachView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        organiser = request.user.organiser
        organiser.favourites.remove(coach_pk)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)
