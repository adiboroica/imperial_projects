# Serializers

DRF serializers for request validation, response shaping, and user registration.

## 📋 Overview

Serializers sit between the API and the models. They validate incoming request data, convert Django model instances to JSON for responses, and handle write-side logic (password hashing, atomic Coach/Organiser creation alongside User).  
Two visibility levels exist for user data: `PublicUserSerializer` for viewing other users and `UserSerializer` for the authenticated user's own profile.

## 📦 Serializer Summary

| Serializer                 | Model     | Purpose                                 | Notable Logic                                                     |
| -------------------------- | --------- | --------------------------------------- | ----------------------------------------------------------------- |
| PublicUserSerializer       | User      | Read-only public profile (other users)  | Excludes email, password, qualification                           |
| UserSerializer             | User      | Full profile for the authenticated user | Password is write-only and hashed on create                       |
| NewCoachUserSerializer     | User      | Coach registration                      | Atomic User + Coach creation, validates username and password     |
| NewOrganiserUserSerializer | User      | Organiser registration                  | Atomic User + Organiser creation, validates username and password |
| EventSerializer            | Event     | Event CRUD                              | Validates date (not past), price (non-negative), time ranges      |
| CoachSerializer            | Coach     | Coach rating data                       | Simple read serializer for cumulative rating fields               |
| OrganiserSerializer        | Organiser | Organiser profile and defaults          | Write-only `favourites_ids`/`blocked_ids` for M2M updates         |

## 🏗️ Design

- **Two user serializers for different visibility** — `PublicUserSerializer` exposes only public fields (name, location, role flags). `UserSerializer` includes email, qualification, and a write-only password field.
- **Registration serializers handle atomic creation** — `NewCoachUserSerializer` and `NewOrganiserUserSerializer` create the User and the profile (Coach/Organiser) inside `@transaction.atomic`. They also set the role flag (`is_coach`/`is_organiser`) and validate password strength via Django's built-in validators.
- **EventSerializer enforces business rules** — date cannot be in the past, price cannot be negative, end time must be after start time (both fixed and flexible). Workflow fields (`coach_user`, `voted`, `offers`) are read-only to prevent client manipulation.
- **OrganiserSerializer uses write-only M2M fields** — `favourites_ids` and `blocked_ids` accept lists of coach PKs on write but are not exposed on read; the read side uses the standard `favourites` and `blocked` M2M fields.

## 🔗 Dependencies

Imports from `models/` only. Never imports from `services/`, `views/`, or `email.py` — serializers validate and shape data; they do not own business logic or side effects. Enforced by import-linter.
