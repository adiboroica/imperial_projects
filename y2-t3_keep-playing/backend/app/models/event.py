from django.db import models

from .user import User


class Event(models.Model):
    name = models.CharField(max_length=50)
    location = models.CharField(max_length=100)
    details = models.CharField(max_length=200)
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    flexible_start_time = models.TimeField()
    flexible_end_time = models.TimeField()
    coach = models.BooleanField()
    price = models.IntegerField()
    coach_user = models.ForeignKey(
        User, related_name='events', on_delete=models.SET_NULL, null=True, blank=True,
    )
    sport = models.CharField(max_length=50)
    role = models.CharField(max_length=50)
    recurring = models.BooleanField(default=False)
    offers = models.ManyToManyField(User, related_name='applied_events', blank=True)
    organiser_user = models.ForeignKey(
        User, related_name='organised_events', on_delete=models.CASCADE, null=False, blank=False,
    )
    creation_started = models.DateTimeField(null=True, blank=True)
    creation_ended = models.DateTimeField(null=True, blank=True)
    voted = models.BooleanField(default=False)
    recurring_end_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.name} ({self.date})"
