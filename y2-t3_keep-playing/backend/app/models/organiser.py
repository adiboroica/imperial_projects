from django.db import models

from .user import User


class Organiser(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    favourites = models.ManyToManyField(User, related_name='favourite_coaches', blank=True)
    blocked = models.ManyToManyField(User, related_name='blocked_coaches', blank=True)
    default_location = models.CharField(max_length=100, blank=True, default='')
    default_price = models.IntegerField(null=True, blank=True)
    default_sport = models.CharField(max_length=50, blank=True, default='')
    default_role = models.CharField(max_length=50, blank=True, default='')

    def __str__(self):
        return f"Organiser: {self.user.username}"
