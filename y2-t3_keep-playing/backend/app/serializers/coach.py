from rest_framework import serializers

from app.models import Coach


class CoachSerializer(serializers.ModelSerializer):
    """Read/write serializer for coach rating fields."""

    class Meta:
        model = Coach
        fields = ['pk', 'user', 'votes', 'experience', 'flexibility', 'reliability']
        validators = []
