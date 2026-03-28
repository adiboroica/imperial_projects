from rest_framework import serializers

from ..models import Event, User


class EventSerializer(serializers.ModelSerializer):
    organiser_user_id = serializers.PrimaryKeyRelatedField(
        many=False, write_only=True, queryset=User.objects.all(),
    )

    def create(self, validated_data):
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
        validators = []
