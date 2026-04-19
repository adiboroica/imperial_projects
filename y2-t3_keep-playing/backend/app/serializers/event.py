from django.utils import timezone
from rest_framework import serializers

from app.models import Event, User


class EventSerializer(serializers.ModelSerializer):
    """Event serializer with date, time, and price validation."""

    organiser_user_id = serializers.PrimaryKeyRelatedField(
        many=False, write_only=True, queryset=User.objects.all(),
    )
    coach = serializers.BooleanField(read_only=True)

    def validate_date(self, value):
        if value < timezone.localdate():
            raise serializers.ValidationError("Event date cannot be in the past.")
        return value

    def validate_price(self, value):
        if value < 0:
            raise serializers.ValidationError("Price cannot be negative.")
        return value

    def validate(self, data):
        """Ensure end times are after their corresponding start times."""
        start = data.get('start_time', getattr(self.instance, 'start_time', None))
        end = data.get('end_time', getattr(self.instance, 'end_time', None))
        if start and end and end <= start:
            raise serializers.ValidationError(
                {"end_time": "End time must be after start time."}
            )
        flex_start = data.get('flexible_start_time', getattr(self.instance, 'flexible_start_time', None))
        flex_end = data.get('flexible_end_time', getattr(self.instance, 'flexible_end_time', None))
        if flex_start and flex_end and flex_end <= flex_start:
            raise serializers.ValidationError(
                {"flexible_end_time": "Flexible end time must be after flexible start time."}
            )
        return data

    def create(self, validated_data):
        """Map organiser_user_id to the FK field and create the event."""
        organiser = validated_data.pop('organiser_user_id', None)
        if organiser is not None:
            validated_data['organiser_user'] = organiser
        event = Event.objects.create(**validated_data)
        return event

    class Meta:
        model = Event
        fields = [
            'pk',
            'name',
            'location',
            'details',
            'date',
            'start_time',
            'end_time',
            'flexible_start_time',
            'flexible_end_time',
            'price',
            'coach',
            'coach_user',
            'sport',
            'role',
            'recurring',
            'recurring_end_date',
            'offers',
            'organiser_user_id',
            'creation_started',
            'creation_ended',
            'voted',
        ]
        read_only_fields = ('coach', 'coach_user', 'voted', 'offers')
        # Suppress auto-generated unique-together validators; field-level
        # validation (validate_date, validate_price, validate) handles constraints.
        validators = []
