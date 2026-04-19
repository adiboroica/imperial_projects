from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from app.permissions import IsCoach
from app.serializers import CoachSerializer, EventSerializer, PublicUserSerializer
from app.services.coach import CoachServiceError, apply_to_event, cancel_assigned_event, get_coach_rating, get_feed_events, get_upcoming_jobs, get_user_profile, unapply_from_event
from app.views._errors import error_response as _error_response


class CoachOrganiserView(APIView):
    """Return a user's public profile by primary key."""

    permission_classes = [IsAuthenticated]

    def get(self, request, pk, format=None):
        try:
            user = get_user_profile(pk)
        except CoachServiceError as e:
            return _error_response(e)
        serializer = PublicUserSerializer(user, many=False)
        return Response(serializer.data)


class CoachEventView(APIView):
    """Apply to an event as a coach."""

    permission_classes = [IsAuthenticated, IsCoach]

    def patch(self, request, pk, format=None):
        try:
            event = apply_to_event(request.user, pk)
        except CoachServiceError as e:
            return _error_response(e)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class CoachUnapplyView(APIView):
    """Withdraw a coach's offer from an event."""

    permission_classes = [IsAuthenticated, IsCoach]

    def patch(self, request, pk, format=None):
        try:
            event = unapply_from_event(request.user, pk)
        except CoachServiceError as e:
            return _error_response(e)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class CoachCancelEventView(APIView):
    """Cancel a coach's accepted assignment on an event."""

    permission_classes = [IsAuthenticated, IsCoach]

    def patch(self, request, pk, format=None):
        try:
            event = cancel_assigned_event(request.user, pk)
        except CoachServiceError as e:
            return _error_response(e)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class CoachFeedView(APIView):
    """List available events a coach can apply to."""

    permission_classes = [IsAuthenticated, IsCoach]

    def get(self, request, format=None):
        events = get_feed_events(request.user)
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)


class CoachUpcomingJobsView(APIView):
    """List events the coach is assigned to."""

    permission_classes = [IsAuthenticated, IsCoach]

    def get(self, request, format=None):
        events = get_upcoming_jobs(request.user)
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)


class CoachModelView(APIView):
    """Return a coach's rating profile."""

    permission_classes = [IsAuthenticated]

    def get(self, request, coach_pk, format=None):
        try:
            coach = get_coach_rating(coach_pk)
        except CoachServiceError as e:
            return _error_response(e)
        serializer = CoachSerializer(coach, many=False)
        return Response(serializer.data)
