from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    is_organiser = models.BooleanField(default=False)
    is_coach = models.BooleanField(default=False)
    location = models.CharField(max_length=100, default='')
    qualification = models.ImageField(null=True, blank=True, upload_to="images/")
    verified = models.BooleanField(default=False)

    def __str__(self):
        return self.username
