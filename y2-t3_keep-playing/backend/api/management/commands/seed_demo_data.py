from django.core.management.base import BaseCommand
from api.models import User, Coach, Organiser, Event
from rest_framework.authtoken.models import Token
from datetime import date, time, timedelta, datetime


class Command(BaseCommand):
    help = 'Seeds the database with demo data for display purposes'

    def handle(self, *args, **options):
        if User.objects.filter(username='organiser_demo').exists():
            self.stdout.write('Demo data already exists, skipping.')
            return

        # Create organiser
        org_user = User.objects.create_user(
            username='organiser_demo',
            password='demo1234',
            first_name='Alice',
            last_name='Smith',
            email='organiser@demo.com',
            location='London',
            is_organiser=True,
        )
        Organiser.objects.create(user=org_user)
        Token.objects.create(user=org_user)

        # Create coach 1
        coach_user = User.objects.create_user(
            username='coach_demo',
            password='demo1234',
            first_name='Bob',
            last_name='Jones',
            email='coach@demo.com',
            location='London',
            is_coach=True,
            verified=True,
        )
        Coach.objects.create(user=coach_user)
        Token.objects.create(user=coach_user)

        # Create coach 2
        coach_user2 = User.objects.create_user(
            username='coach_demo2',
            password='demo1234',
            first_name='Charlie',
            last_name='Brown',
            email='coach2@demo.com',
            location='Manchester',
            is_coach=True,
        )
        Coach.objects.create(user=coach_user2)
        Token.objects.create(user=coach_user2)

        today = date.today()
        now = datetime.now()

        # Event 1: Pending, no offers
        Event.objects.create(
            name='Saturday Football Training',
            sport='Football',
            role='Coach',
            date=today + timedelta(days=30),
            location='Imperial College Sports Centre',
            details='Weekly football training session for beginners',
            price=50,
            coach=False,
            start_time=time(10, 0),
            end_time=time(12, 0),
            flexible_start_time=time(9, 30),
            flexible_end_time=time(12, 30),
            organiser_user=org_user,
            creation_started=now,
            creation_ended=now,
        )

        # Event 2: Pending, with an offer from Bob
        e2 = Event.objects.create(
            name='Basketball Tournament',
            sport='Basketball',
            role='Referee',
            date=today + timedelta(days=14),
            location='Crystal Palace National Sports Centre',
            details='Referee needed for inter-university basketball tournament',
            price=75,
            coach=False,
            start_time=time(14, 0),
            end_time=time(17, 0),
            flexible_start_time=time(13, 30),
            flexible_end_time=time(17, 30),
            organiser_user=org_user,
            creation_started=now,
            creation_ended=now,
        )
        e2.offers.add(coach_user)

        # Event 3: Scheduled (coach assigned)
        Event.objects.create(
            name='Swimming Lessons',
            sport='Swimming',
            role='Coach',
            date=today + timedelta(days=7),
            location='London Aquatics Centre',
            details='Swimming lessons for children aged 8-12',
            price=40,
            coach=True,
            coach_user=coach_user,
            start_time=time(9, 0),
            end_time=time(10, 30),
            flexible_start_time=time(8, 30),
            flexible_end_time=time(11, 0),
            organiser_user=org_user,
            creation_started=now,
            creation_ended=now,
        )

        # Event 4: Pending, no offers
        Event.objects.create(
            name='Cricket Match',
            sport='Cricket',
            role='Referee',
            date=today + timedelta(days=21),
            location='The Oval',
            details='Umpire needed for friendly cricket match',
            price=60,
            coach=False,
            start_time=time(11, 0),
            end_time=time(16, 0),
            flexible_start_time=time(10, 30),
            flexible_end_time=time(16, 30),
            organiser_user=org_user,
            creation_started=now,
            creation_ended=now,
        )

        # Add Bob to Alice's favourites
        org_user.organiser.favourites.add(coach_user)

        self.stdout.write(self.style.SUCCESS('Demo data seeded successfully.'))
