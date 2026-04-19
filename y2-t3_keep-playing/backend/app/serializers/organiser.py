from rest_framework import serializers

from app.models import Organiser, User


class OrganiserSerializer(serializers.ModelSerializer):
    """Serializer for organiser profiles including favourites and defaults."""

    favourites_ids = serializers.PrimaryKeyRelatedField(
        many=True, write_only=True, queryset=User.objects.filter(is_coach=True),
    )
    blocked_ids = serializers.PrimaryKeyRelatedField(
        many=True, write_only=True, queryset=User.objects.filter(is_coach=True),
    )

    def update(self, instance, validated_data):
        """Sync favourites/blocked M2M relations and update default fields."""
        favourites = validated_data.pop('favourites_ids', None)
        if favourites is not None:
            instance.favourites.set(favourites)
        blocked = validated_data.pop('blocked_ids', None)
        if blocked is not None:
            instance.blocked.set(blocked)
        instance.default_price = validated_data.get('default_price', instance.default_price)
        instance.default_sport = validated_data.get('default_sport', instance.default_sport)
        instance.default_role = validated_data.get('default_role', instance.default_role)
        instance.default_location = validated_data.get('default_location', instance.default_location)
        instance.save()
        return instance

    class Meta:
        model = Organiser
        fields = [
            'pk',
            'favourites',
            'blocked',
            'user',
            'favourites_ids',
            'blocked_ids',
            'default_location',
            'default_price',
            'default_sport',
            'default_role',
        ]
        # Suppress auto-generated validators; update() handles M2M and
        # default fields directly.
        validators = []
