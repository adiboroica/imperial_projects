from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token

from .views import (
    AcceptOfferView,
    CoachCancelEventView,
    CoachEventView,
    CoachFeedView,
    CoachModelView,
    CoachOrganiserView,
    CoachUpcomingJobsView,
    CoachUnapplyView,
    CreateCoachUser,
    CreateOrganiserUser,
    EventGetOrganiserView,
    EventView,
    HelloView,
    OrganiserAddFavouriteCoachView,
    OrganiserBlockCoachView,
    OrganiserRemoveFavouriteCoachView,
    OrganiserUnblockCoachView,
    OrganiserView,
    UserRecordView,
    UsersRecordView,
    VoteCoachView,
)

urlpatterns = [
    # Auth
    path('login/', obtain_auth_token, name='login'),
    path('new_coach/', CreateCoachUser.as_view(), name='new-coach'),
    path('new_organiser/', CreateOrganiserUser.as_view(), name='new-organiser'),

    # Users
    path('hello/', HelloView.as_view(), name='hello'),
    path('users/', UsersRecordView.as_view(), name='users'),
    path('user/', UserRecordView.as_view(), name='user'),

    # Coach actions
    path('coach/feed/', CoachFeedView.as_view(), name='coach-feed'),
    path('coach/upcoming-jobs/', CoachUpcomingJobsView.as_view(), name='coach-upcoming-jobs'),
    path('coach/events/<int:pk>/apply/', CoachEventView.as_view(), name='coach-apply'),
    path('coach/events/<int:pk>/unapply/', CoachUnapplyView.as_view(), name='coach-unapply'),
    path('coach/events/<int:pk>/cancel/', CoachCancelEventView.as_view(), name='coach-cancel'),
    path('coach/<int:pk>/', CoachOrganiserView.as_view(), name='coach-detail'),

    # Organiser actions
    path('organiser/', OrganiserView.as_view(), name='organiser'),
    path('organiser/events/', EventView.as_view(), name='organiser-events'),
    path('organiser/events/<int:pk>/', EventView.as_view(), name='organiser-event-detail'),
    path('organiser/events/<int:pk>/accept/<int:coach_pk>/', AcceptOfferView.as_view(), name='accept-offer'),
    path('organiser/block/<int:coach_pk>/', OrganiserBlockCoachView.as_view(), name='organiser-block'),
    path('organiser/unblock/<int:coach_pk>/', OrganiserUnblockCoachView.as_view(), name='organiser-unblock'),
    path('organiser/add-favourite/<int:coach_pk>/', OrganiserAddFavouriteCoachView.as_view(), name='organiser-add-favourite'),
    path('organiser/remove-favourite/<int:coach_pk>/', OrganiserRemoveFavouriteCoachView.as_view(), name='organiser-remove-favourite'),
    path('organiser/vote/<int:event_pk>/', VoteCoachView.as_view(), name='vote-coach'),
    path('organiser/coach-model/<int:coach_pk>/', CoachModelView.as_view(), name='coach-model'),
    path('organiser/<int:pk>/', CoachOrganiserView.as_view(), name='organiser-detail'),

    # Event cross-cutting
    path('event/<int:pk>/organiser/', EventGetOrganiserView.as_view(), name='event-organiser'),
]
