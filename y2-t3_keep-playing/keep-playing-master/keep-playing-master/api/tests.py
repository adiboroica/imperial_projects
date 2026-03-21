from django.test import TestCase
from pytz import timezone
from .models import Event
from datetime import datetime

class TestEventModel(TestCase):
  def setUp(self):
    self.event = Event(name="Test event", 
      date=datetime.now().date(), 
      location="", 
      details="",
      start_time=datetime.now().time(),
      end_time=datetime.now().time(),
      flexible_start_time=datetime.now().time(),
      flexible_end_time=datetime.now().time(),
      coach=False,
      price=0
    )
    self.event.save()

  def test_basic_event(self): 
    self.assertEqual(Event.objects.count(), 1)
