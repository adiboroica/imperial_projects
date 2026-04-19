import os
from pathlib import Path

import environ

env = environ.Env()

BASE_DIR = Path(__file__).resolve().parent.parent

# Read .env from explicit path, backend/, or project root (parent of backend/)
_env_file = os.environ.get('ENV_FILE')
if _env_file is None:
    for candidate in [BASE_DIR / '.env', BASE_DIR.parent / '.env']:
        if candidate.is_file():
            _env_file = str(candidate)
            break
if _env_file:
    environ.Env.read_env(env_file=_env_file, overwrite=False)

SECRET_KEY = env('SECRET_KEY', default='django-insecure-dev-key-change-in-production')

DEBUG = env.bool('DEBUG', default=False)

if not DEBUG and SECRET_KEY.startswith('django-insecure'):
    raise ValueError('You must set a real SECRET_KEY when DEBUG=False')

if not DEBUG and env('POSTGRES_PASSWORD', default='keepplaying') == 'keepplaying':
    raise ValueError('You must set a real POSTGRES_PASSWORD when DEBUG=False')

ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['localhost', '127.0.0.1', 'backend'])

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework.authtoken',
    'django_q',
    'app',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# Database

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': env('POSTGRES_DB_NAME', default='keep_playing'),
        'USER': env('POSTGRES_USER', default='keepplaying'),
        'PASSWORD': env('POSTGRES_PASSWORD', default='keepplaying'),
        'HOST': env('POSTGRES_HOST', default='localhost'),
        'PORT': env('POSTGRES_PORT', default='5432'),
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]
AUTH_USER_MODEL = 'app.User'

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'app.authentication.ExpiringTokenAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 50,
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '20/minute',
        'user': '60/minute',
        'signup': '5/hour',
        'login_username': '10/hour',
    },
}

# Structured-ish logging — includes timestamp, level, logger name, message.
# Dev keeps Django's default human-readable format; prod uses key=value pairs
# that are easier for log aggregators to parse (without adding a JSON-logger dep).
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'dev': {
            'format': '[{levelname}] {name}: {message}',
            'style': '{',
        },
        'prod': {
            'format': 'ts={asctime} level={levelname} logger={name} msg={message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'dev' if DEBUG else 'prod',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'app': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Static & media files

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'assets'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# --- DEPRECATED: S3 Storage ---
# Disabled by default. Set USE_S3=TRUE to enable cloud storage.
# When enabled, requires AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
# and AWS_STORAGE_BUCKET_NAME environment variables.

USE_S3 = env.bool('USE_S3', default=False)

if USE_S3:
    INSTALLED_APPS += ['storages']
    AWS_ACCESS_KEY_ID = env('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = env('AWS_SECRET_ACCESS_KEY')
    AWS_STORAGE_BUCKET_NAME = env('AWS_STORAGE_BUCKET_NAME')
    AWS_DEFAULT_ACL = 'private'
    AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
    AWS_S3_OBJECT_PARAMETERS = {'CacheControl': 'max-age=86400'}
    AWS_LOCATION = 'assets'
    STATIC_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/{AWS_LOCATION}/'
    STORAGES = {
        'default': {'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage'},
        'staticfiles': {'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage'},
    }

# --- DEPRECATED: Mailgun Email ---
# Disabled by default. Set EMAIL_NOTIFICATIONS_ENABLED=True and provide
# MAILGUN_SMTP_LOGIN / MAILGUN_SMTP_PASSWORD to enable email sending.

EMAIL_NOTIFICATIONS_ENABLED = env.bool('EMAIL_NOTIFICATIONS_ENABLED', default=False)

if EMAIL_NOTIFICATIONS_ENABLED:
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = 'smtp.mailgun.org'
    EMAIL_PORT = 587
    EMAIL_HOST_USER = env('MAILGUN_SMTP_LOGIN', default='')
    EMAIL_HOST_PASSWORD = env('MAILGUN_SMTP_PASSWORD', default='')
else:
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# --- Security hardening (production) ---

if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_REFERRER_POLICY = 'same-origin'
    SECURE_CROSS_ORIGIN_OPENER_POLICY = 'same-origin'
    SESSION_COOKIE_SAMESITE = 'Strict'
    CSRF_COOKIE_SAMESITE = 'Strict'

# --- CSRF trusted origins ---
# Required for HTTPS deployments and any cross-origin POST/PATCH/DELETE from
# a Flutter mobile app or separately-hosted web frontend.
CSRF_TRUSTED_ORIGINS = env.list('CSRF_TRUSTED_ORIGINS', default=[])

# --- Token expiry ---
# Tokens older than this are rejected. Set to 0 to disable.
TOKEN_EXPIRY_HOURS = env.int('TOKEN_EXPIRY_HOURS', default=72)

# --- Background tasks (django-q2) ---
# Uses Postgres as broker, so no Redis container is required. The worker runs
# as the `backend-worker` service in docker-compose (`python manage.py qcluster`).
# Set Q_SYNC=True in test runs to execute tasks inline rather than via the queue.
Q_CLUSTER = {
    'name': 'keep_playing',
    'orm': 'default',
    'workers': 2,
    'timeout': 60,
    'retry': 120,
    'save_limit': 250,
    'catch_up': False,
    'max_attempts': 3,
    'sync': env.bool('Q_SYNC', default=False),
}
