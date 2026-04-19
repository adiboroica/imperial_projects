#!/bin/bash
set -e

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

if [ "${SEED_DEMO_DATA}" = "True" ]; then
    echo "Seeding demo data..."
    python manage.py seed_demo_data
fi

echo "Starting server..."
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --log-file - --log-level info
