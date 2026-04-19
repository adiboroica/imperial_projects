from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from app.permissions import IsOrganiser
from app.serializers import CoachSerializer, EventSerializer, OrganiserSerializer
from app.services.organiser import OrganiserServiceError, accept_offer, add_favourite, block_coach, remove_favourite, unblock_coach, vote_coach
from app.views._errors import error_response as _error_response


class OrganiserView(APIView):
    """Retrieve or update the authenticated organiser's profile."""

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
            {"error": True, "error_msg": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class AcceptOfferView(APIView):
    """Accept a coach's offer for an event."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, pk, coach_pk, format=None):
        try:
            event = accept_offer(request.user, pk, coach_pk)
        except OrganiserServiceError as e:
            return _error_response(e)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserBlockCoachView(APIView):
    """Block a coach from applying to the organiser's events."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        try:
            organiser = block_coach(request.user, coach_pk)
        except OrganiserServiceError as e:
            return _error_response(e)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserUnblockCoachView(APIView):
    """Unblock a previously blocked coach."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        try:
            organiser = unblock_coach(request.user, coach_pk)
        except OrganiserServiceError as e:
            return _error_response(e)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserAddFavouriteCoachView(APIView):
    """Add a coach to the organiser's favourites list."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        try:
            organiser = add_favourite(request.user, coach_pk)
        except OrganiserServiceError as e:
            return _error_response(e)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class OrganiserRemoveFavouriteCoachView(APIView):
    """Remove a coach from the organiser's favourites list."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, coach_pk, format=None):
        try:
            organiser = remove_favourite(request.user, coach_pk)
        except OrganiserServiceError as e:
            return _error_response(e)
        serializer = OrganiserSerializer(organiser, many=False)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class VoteCoachView(APIView):
    """Submit experience/flexibility/reliability ratings for a coach after an event."""

    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, event_pk, format=None):
        try:
            raw_exp = request.data["experience"]
            raw_flex = request.data["flexibility"]
            raw_rel = request.data["reliability"]
        except KeyError:
            return Response(
                {"error": True, "error_msg": "experience, flexibility, and reliability are required integers"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        # Reject bool explicitly (isinstance(True, int) is True; int(True) is 1).
        for raw in (raw_exp, raw_flex, raw_rel):
            if isinstance(raw, bool):
                return Response(
                    {"error": True, "error_msg": "experience, flexibility, and reliability are required integers"},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        try:
            exp = int(raw_exp)
            flex = int(raw_flex)
            rel = int(raw_rel)
        except (TypeError, ValueError):
            return Response(
                {"error": True, "error_msg": "experience, flexibility, and reliability are required integers"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            coach = vote_coach(request.user, event_pk, exp, flex, rel)
        except OrganiserServiceError as e:
            return _error_response(e)
        serializer = CoachSerializer(coach, many=False)
        return Response(serializer.data)
