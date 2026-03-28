from rest_framework import serializers

from ..models import Coach


class CoachSerializer(serializers.ModelSerializer):

    class Meta:
        model = Coach
        fields = ['pk', 'user', 'votes', 'experience', 'flexibility', 'reliability']
        validators = []
