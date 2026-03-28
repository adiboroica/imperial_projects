from rest_framework import serializers
from rest_framework.validators import UniqueTogetherValidator

from ..models import Coach, Organiser, User


class UserSerializer(serializers.ModelSerializer):

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = User(**validated_data)
        if password:
            user.set_password(password)
        user.save()
        return user

    class Meta:
        model = User
        fields = (
            'pk',
            'username',
            'first_name',
            'last_name',
            'location',
            'email',
            'password',
            'is_coach',
            'is_organiser',
            'qualification',
            'verified',
        )
        extra_kwargs = {
            'password': {'write_only': True},
        }
        validators = [
            UniqueTogetherValidator(
                queryset=User.objects.all(),
                fields=['username', 'email'],
            )
        ]


class NewCoachUserSerializer(serializers.ModelSerializer):

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError('A user with this username already exists.')
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
        )
        user.qualification = validated_data.get('qualification')
        user.is_coach = True
        user.save()
        Coach.objects.create(user=user)
        return user

    class Meta:
        model = User
        fields = ('pk', 'username', 'password', 'qualification')
        validators = []


class NewOrganiserUserSerializer(serializers.ModelSerializer):

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError('A user with this username already exists.')
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
        )
        user.qualification = validated_data.get('qualification')
        user.is_organiser = True
        user.save()
        Organiser.objects.create(user=user)
        return user

    class Meta:
        model = User
        fields = ('pk', 'username', 'password', 'qualification')
        validators = []
