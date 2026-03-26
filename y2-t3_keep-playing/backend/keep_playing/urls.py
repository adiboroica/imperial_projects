from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken.views import obtain_auth_token
from api import views
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls', namespace='api')),
    path('hello/', views.HelloView.as_view(), name='hello'),
    path('users/', views.UsersRecordView.as_view(), name='users'),
    path('user/', views.UserRecordView.as_view(), name='user'),
    path('coach/events/<int:pk>/apply/', views.CoachEventView.as_view(), name='apply'),
    path('coach/events/<int:pk>/unapply/', views.CoachUnapplyView.as_view(), name='unapply'),
    path('coach/events/<int:pk>/cancel/', views.CoachCancelEventView.as_view(), name='cancel'),
    path('coach/<int:pk>/', views.CoachEventView.as_view(), name='coach'),
    path('organiser/<int:pk>/', views.CoachOrganiserView.as_view(), name='organiser_view'),
    path('organiser/', views.OrganiserView.as_view(), name='organiser'),
    path('organiser/events/', views.EventView.as_view(), name='events'),
    path('organiser/events/<int:pk>/', views.EventView.as_view(), name='events'),
    path('organiser/events/<int:pk>/accept/<int:coach_pk>/', views.AcceptOfferView.as_view(), name='apply'),
    path('organiser/block/<int:coach_pk>/', views.OrganiserBlockCoachView.as_view(), name='organiser_block'),
    path('organiser/unblock/<int:coach_pk>/', views.OrganiserUnblockCoachView.as_view(), name='organiser_unblock'),
    path('organiser/add-favourite/<int:coach_pk>/', views.OrganiserAddFavouriteCoachView.as_view(), name='organiser_add_favourite'),
    path('organiser/remove-favourite/<int:coach_pk>/', views.OrganiserRemoveFavouriteCoachView.as_view(), name='organiser_remove_favorite'),
    # path('organiser/events/', views.OrganiserEventsView.as_view(), name='organiser_events'),
    path('coach/feed/', views.CoachFeedView.as_view(), name='coach_feed'),
    path('coach/upcoming-jobs/', views.CoachUpcomingJobsView.as_view(), name='coach_upcoming_jobs'),
    path('organiser/vote/<int:event_pk>/', views.VoteCoachView.as_view(), name='vote_coach'),
    path('organiser/coach-model/<int:coach_pk>/', views.CoachModelView.as_view(), name='coach_model'),
    path('new_coach/', views.CreateCoachUser.as_view(), name='new_coach'),
    path('new_organiser/', views.CreateOrganiserUser.as_view(), name='new_organiser'),
    path('event/<int:pk>/organiser/', views.EventGetOrganiserView.as_view(), name='organiser_for_event'),
    path('login/', obtain_auth_token, name='login'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


