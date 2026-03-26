#!/bin/bash
set -e

echo "Removing old incremental migrations..."
find /app/api/migrations -name '0*.py' -delete

echo "Generating fresh migrations from current models..."
python manage.py makemigrations api --noinput

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Seeding demo data..."
python manage.py seed_demo_data

echo "Starting server..."
exec gunicorn keep_playing.wsgi:application --bind 0.0.0.0:8000 --log-file - --log-level info
