from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models

MAX_UPLOAD_SIZE = 5 * 1024 * 1024  # 5 MB


def validate_file_size(value):
    if value.size > MAX_UPLOAD_SIZE:
        raise ValidationError(f"File size must be at most {MAX_UPLOAD_SIZE // (1024 * 1024)} MB.")


class User(AbstractUser):
    """Custom user with role flags and qualification support."""

    is_organiser = models.BooleanField(default=False)
    is_coach = models.BooleanField(default=False)
    location = models.CharField(max_length=100, default='')
    qualification = models.ImageField(
        null=True, blank=True, upload_to="images/", validators=[validate_file_size],
    )
    verified = models.BooleanField(default=False)

    def __str__(self):
        return self.username
