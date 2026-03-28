from rest_framework.permissions import BasePermission


class IsOrganiser(BasePermission):
    """Allow access only to users with is_organiser=True."""

    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_organiser


class IsCoach(BasePermission):
    """Allow access only to users with is_coach=True."""

    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_coach
