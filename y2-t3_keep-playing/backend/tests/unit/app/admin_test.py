"""Smoke tests for admin.py.

These don't exercise the Django admin UI end-to-end (that would require a
browser). They just make sure the ``UserAdmin`` configuration references
real fields and registers the right inlines, so a typo or a renamed field
surfaces in the test suite rather than only when an admin opens the page.
"""
import pytest
from django.contrib import admin as django_admin

from app.admin import CoachInline, OrganiserInline, UserAdmin
from app.models import Coach, Event, Organiser, User


@pytest.mark.django_db
class UserAdminTest:

    def test_registered(self):
        assert django_admin.site.is_registered(User)

    def test_list_display_includes_role_flags(self):
        assert 'is_coach' in UserAdmin.list_display
        assert 'is_organiser' in UserAdmin.list_display

    def test_inlines_present(self):
        inlines = UserAdmin.inlines
        assert CoachInline in inlines
        assert OrganiserInline in inlines

    def test_fieldsets_reference_real_fields(self):
        # Flatten the tuple-of-tuple fieldsets and check every field name resolves.
        all_fields = set()
        for _label, opts in UserAdmin.fieldsets:
            all_fields.update(opts.get('fields', ()))
        model_fields = {f.name for f in User._meta.get_fields()}
        # The "Additional Fields" section we added must be in the model.
        for name in ('location', 'is_organiser', 'is_coach', 'qualification', 'verified'):
            assert name in all_fields, f'{name} missing from UserAdmin.fieldsets'
            assert name in model_fields, f'{name} missing from User model'


@pytest.mark.django_db
class ModelRegistrationTest:

    def test_event_registered(self):
        assert django_admin.site.is_registered(Event)

    def test_coach_registered(self):
        assert django_admin.site.is_registered(Coach)

    def test_organiser_registered(self):
        assert django_admin.site.is_registered(Organiser)
