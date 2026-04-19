import pytest
from unittest.mock import Mock

from app.permissions import IsCoach, IsOrganiser


class IsCoachTest:

    def test_grants_coach(self):
        request = Mock()
        request.user.is_authenticated = True
        request.user.is_coach = True
        assert IsCoach().has_permission(request, view=None) is True

    def test_denies_organiser(self):
        request = Mock()
        request.user.is_authenticated = True
        request.user.is_coach = False
        assert IsCoach().has_permission(request, view=None) is False

    def test_denies_anonymous(self):
        request = Mock()
        request.user.is_authenticated = False
        assert IsCoach().has_permission(request, view=None) is False


class IsOrganiserTest:

    def test_grants_organiser(self):
        request = Mock()
        request.user.is_authenticated = True
        request.user.is_organiser = True
        assert IsOrganiser().has_permission(request, view=None) is True

    def test_denies_coach(self):
        request = Mock()
        request.user.is_authenticated = True
        request.user.is_organiser = False
        assert IsOrganiser().has_permission(request, view=None) is False

    def test_denies_anonymous(self):
        request = Mock()
        request.user.is_authenticated = False
        assert IsOrganiser().has_permission(request, view=None) is False
