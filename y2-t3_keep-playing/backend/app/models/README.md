# Models

Django models defining the Keep Playing domain.

## 📋 Overview

The domain is built around a two-role user system. A single `User` model carries role flags (`is_coach`, `is_organiser`), and each role has a profile extension linked via `OneToOneField`. `Event` is the central entity — it connects an organiser to a coach through an offers-and-acceptance workflow.

## 📦 Model Summary

| Model     | Extends / Links              | Purpose                                                          |
| --------- | ---------------------------- | ---------------------------------------------------------------- |
| User      | `AbstractUser`               | Authentication and shared fields (location, qualification, role) |
| Coach     | OneToOne to User (PK)        | Coach profile with cumulative rating scores                      |
| Organiser | OneToOne to User (PK)        | Organiser profile with favourites, block list, and defaults      |
| Event     | FK to User (organiser/coach) | A coaching session with date, sport, role, price, and offers     |

## 🔗 Relationships

| Relationship                | Type       | On Delete | Description                                   |
| --------------------------- | ---------- | --------- | --------------------------------------------- |
| Coach → User                | OneToOne   | CASCADE   | Coach profile is destroyed with the user      |
| Organiser → User            | OneToOne   | CASCADE   | Organiser profile is destroyed with the user  |
| Event → organiser_user      | ForeignKey | CASCADE   | Every event belongs to exactly one organiser  |
| Event → coach_user          | ForeignKey | SET_NULL  | Assigned coach (nullable — unassigned events) |
| Event.offers → User         | ManyToMany | —         | Coaches who have applied for the event        |
| Organiser.favourites → User | ManyToMany | —         | Coaches the organiser has favourited          |
| Organiser.blocked → User    | ManyToMany | —         | Coaches the organiser has blocked             |

## 🏗️ Design

- **Role flags on User, profiles as extensions** — `is_coach` and `is_organiser` live on User for quick permission checks. Detailed profile data (ratings, defaults) lives on Coach/Organiser, linked via OneToOne with `primary_key=True`.
- **Cumulative ratings** — Coach stores running totals (`votes`, `experience`, `flexibility`, `reliability`), not per-event scores. Averages are computed at read time by dividing each score by `votes`.
- **Computed `coach` property** — `Event.coach` is a property (`coach_user_id is not None`), not a stored field. It indicates whether a coach has been assigned.
- **Organiser defaults** — `default_location`, `default_price`, `default_sport`, `default_role` pre-fill new events in the frontend.

## 🔗 Dependencies

No internal dependencies. Models are the leaf of the app's dependency graph — they never import from `serializers/`, `services/`, `views/`, or `email.py`. Enforced by import-linter.
