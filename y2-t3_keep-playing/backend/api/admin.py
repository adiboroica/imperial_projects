from django.contrib import admin
from api.models import Event, User, Coach, Organiser
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin


class CoachInline(admin.TabularInline):
    model = Coach
    
class OrganiserInline(admin.TabularInline):
    model = Organiser

@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    inlines = [CoachInline, OrganiserInline]
    list_display = DjangoUserAdmin.list_display + ('is_coach', 'is_organiser')
    fieldsets = DjangoUserAdmin.fieldsets+ (
        (                      
            'Additional Fields', # you can also use None 
            {
                'fields': (
                    'location', 'is_organiser', 'is_coach', 'qualification', 'verified'
                ),
            },
        ),
    )


class EventAdmin(admin.ModelAdmin):
    list_display = ('name', 'location', 'date', 'organiser_user', 'sport', 'role', 'coach_user')
admin.site.register(Event, EventAdmin)

admin.site.register(Coach)
admin.site.register(Organiser)
