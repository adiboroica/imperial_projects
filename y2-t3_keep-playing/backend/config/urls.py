from django.contrib import admin
from django.urls import path, re_path, include
from django.conf import settings
from django.views.static import serve

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('app.urls')),
]

# Serve media files via Django ONLY in local development. In production nginx
# serves the shared `media_data` volume directly (see frontend/nginx.conf) —
# django.views.static.serve is not production-hardened (no caching, no range
# requests). If USE_S3=True, uploads live on S3 regardless.
if settings.DEBUG and not getattr(settings, 'USE_S3', False):
    urlpatterns += [
        re_path(r'^media/(?P<path>.+)$', serve, {'document_root': settings.MEDIA_ROOT}),
    ]
