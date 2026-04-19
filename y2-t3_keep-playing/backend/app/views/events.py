from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from app.permissions import IsOrganiser
from app.serializers import CoachSerializer, EventSerializer, PublicUserSerializer
from app.services.event import EventServiceError, create_event, delete_event, fetch_event_for_update, get_event_offers, get_event_organiser, get_organiser_events
from app.views._errors import error_response as _error_response


class EventView(APIView):
    """CRUD operations for organiser-owned events."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def get(self, request, format=None):
        events = get_organiser_events(request.user)
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)

    def post(self, request):
        data = request.data.copy()
        data['organiser_user_id'] = request.user.pk
        serializer = EventSerializer(data=data)
        if serializer.is_valid():
            event = create_event(request.user, serializer.validated_data)
            return Response(EventSerializer(event).data, status=status.HTTP_201_CREATED)
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )

    def delete(self, request, pk, format=None):
        try:
            delete_event(request.user, pk)
        except EventServiceError as e:
            return _error_response(e)
        return Response({'message': 'Deleted'})

    def patch(self, request, pk, format=None):
        data = request.data.copy()
        for field in ('coach_user', 'coach', 'voted', 'offers', 'organiser_user_id'):
            data.pop(field, None)
        try:
            event = fetch_event_for_update(request.user, pk)
        except EventServiceError as e:
            return _error_response(e)
        serializer = EventSerializer(event, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_202_ACCEPTED)
        return Response(
            {"error": True, "error_msg": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class EventOffersView(APIView):
    """List coach offers for a specific event."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def get(self, request, pk, format=None):
        try:
            offer_users = get_event_offers(request.user, pk)
        except EventServiceError as e:
            return _error_response(e)
        results = []
        for user in offer_users:
            entry = PublicUserSerializer(user).data
            # No N+1: the service prefetched `coach` via select_related.
            # hasattr catches RelatedObjectDoesNotExist when Coach row is absent.
            if hasattr(user, 'coach'):
                entry['rating'] = CoachSerializer(user.coach).data
            results.append(entry)
        return Response(results)


class EventGetOrganiserView(APIView):
    """Return the organiser's public profile for a given event."""

    permission_classes = [IsAuthenticated]

    def get(self, request, pk, format=None):
        try:
            organiser_user = get_event_organiser(pk)
        except EventServiceError as e:
            return _error_response(e)
        serializer = PublicUserSerializer(organiser_user, many=False)
        return Response(serializer.data)
