from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from ..email import notify_organiser_coach_cancelled, notify_organiser_new_offer
from ..models import Coach, Event, Organiser, User
from ..permissions import IsCoach, IsOrganiser
from ..serializers import CoachSerializer, EventSerializer, UserSerializer


class CoachOrganiserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk, format=None):
        user = get_object_or_404(User, pk=pk)
        serializer = UserSerializer(user, many=False)
        return Response(serializer.data)


class CoachEventView(APIView):
    permission_classes = [IsAuthenticated, IsCoach]

    def get(self, request, pk, format=None):
        user = get_object_or_404(User, pk=pk)
        serializer = UserSerializer(user, many=False)
        return Response(serializer.data)

    def patch(self, request, pk, format=None):
        event = get_object_or_404(Event, pk=pk)
        event.offers.add(request.user)
        notify_organiser_new_offer(event.organiser_user, request.user, event)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class CoachUnapplyView(APIView):
    permission_classes = [IsAuthenticated, IsCoach]

    def patch(self, request, pk, format=None):
        event = get_object_or_404(Event, pk=pk)
        event.offers.remove(request.user)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class CoachCancelEventView(APIView):
    permission_classes = [IsAuthenticated, IsCoach]

    def patch(self, request, pk, format=None):
        event = get_object_or_404(Event, pk=pk)
        event.coach = False
        event.coach_user = None
        event.save()
        event.offers.remove(request.user)
        notify_organiser_coach_cancelled(event.organiser_user, event)
        serializer = EventSerializer(event)
        return Response(serializer.data, status=status.HTTP_202_ACCEPTED)


class CoachFeedView(APIView):
    permission_classes = [IsAuthenticated, IsCoach]

    def get(self, request, format=None):
        now = timezone.now()
        blocked_by = Organiser.objects.filter(
            blocked=request.user,
        ).values_list('user_id', flat=True)
        events = Event.objects.filter(
            date__gte=now, coach_user__isnull=True,
        ).exclude(
            organiser_user_id__in=blocked_by,
        ).order_by('date')
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)


class CoachUpcomingJobsView(APIView):
    permission_classes = [IsAuthenticated, IsCoach]

    def get(self, request, format=None):
        now = timezone.now()
        events = Event.objects.filter(
            coach_user=request.user, date__gte=now,
        ).order_by('date')
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)


class VoteCoachView(APIView):
    permission_classes = [IsAuthenticated, IsOrganiser]

    def patch(self, request, event_pk, format=None):
        event = get_object_or_404(Event, pk=event_pk)
        if event.coach_user is None:
            return Response(
                {"error": True, "error_msg": "Event has no assigned coach"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        coach = event.coach_user.coach
        if not event.voted:
            event.voted = True
            event.save()
            coach.votes += 1
            coach.experience += request.data["experience"]
            coach.flexibility += request.data["flexibility"]
            coach.reliability += request.data["reliability"]
            coach.save()
        serializer = CoachSerializer(coach, many=False)
        return Response(serializer.data)


class CoachModelView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, coach_pk, format=None):
        user = get_object_or_404(User, pk=coach_pk)
        coach = user.coach
        serializer = CoachSerializer(coach, many=False)
        return Response(serializer.data)
