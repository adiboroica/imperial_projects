from django.db import models

from .user import User


class Coach(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    votes = models.IntegerField(default=0)
    experience = models.IntegerField(default=0)
    flexibility = models.IntegerField(default=0)
    reliability = models.IntegerField(default=0)

    def __str__(self):
        return f"Coach: {self.user.username}"
