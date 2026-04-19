from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import transaction
from rest_framework import serializers
from rest_framework.validators import UniqueTogetherValidator

from app.models import Coach, Organiser, User


class PublicUserSerializer(serializers.ModelSerializer):
    """Limited fields for viewing other users' profiles."""

    class Meta:
        model = User
        fields = (
            'pk',
            'username',
            'first_name',
            'last_name',
            'location',
            'is_coach',
            'is_organiser',
            'verified',
        )


class UserSerializer(serializers.ModelSerializer):
    """Full user serializer with password hashing on create."""

    def create(self, validated_data):
        """Hash password before saving the new user."""
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
    """Registers a new user and creates their linked Coach profile."""

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError('A user with this username already exists.')
        return value

    def validate_password(self, value):
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value

    @transaction.atomic
    def create(self, validated_data):
        """Create user with hashed password and linked Coach profile."""
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
            email=validated_data.get('email', ''),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        user.qualification = validated_data.get('qualification')
        user.is_coach = True
        user.save()
        Coach.objects.create(user=user)
        return user

    class Meta:
        model = User
        fields = ('pk', 'username', 'password', 'qualification', 'email', 'first_name', 'last_name')
        # Suppress auto-generated validators; validate_username and
        # validate_password handle uniqueness and strength checks.
        validators = []


class NewOrganiserUserSerializer(serializers.ModelSerializer):
    """Registers a new user and creates their linked Organiser profile."""

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError('A user with this username already exists.')
        return value

    def validate_password(self, value):
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value

    @transaction.atomic
    def create(self, validated_data):
        """Create user with hashed password and linked Organiser profile."""
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
            email=validated_data.get('email', ''),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        user.qualification = validated_data.get('qualification')
        user.is_organiser = True
        user.save()
        Organiser.objects.create(user=user)
        return user

    class Meta:
        model = User
        fields = ('pk', 'username', 'password', 'qualification', 'email', 'first_name', 'last_name')
        # Suppress auto-generated validators; validate_username and
        # validate_password handle uniqueness and strength checks.
        validators = []
