# Sri Lanka Tourism Website

This repository currently contains the initial project structure for a tourism
website where visitors can book a ready-made tour or plan a custom journey with
the company's drivers and vehicles.

The structure is organized for a Next.js App Router application with TypeScript.
It is a scaffold only: application code, dependencies, credentials, and deployment
configuration have not been added.

## Project structure

```text
public/
  assets/
    brand/             Logos and brand artwork
    destinations/      Destination photos and media
    drivers/           Driver profile photos
    hero/frames/       Optimized scroll-hero image frames
    packages/          Tour package photos
    vehicles/          Vehicle photos
src/
  app/                 Pages and route handlers
    about/ contact/ faq/ privacy/ reviews/ terms/
    admin/
      bookings/ packages/ drivers/ vehicles/ settings/
    api/
      bookings/
      payments/webhook/
    booking/[bookingId]/
      confirmation/
      driver/
    destinations/[slug]/
    journey/summary/
    packages/[slug]/
    checkout/
  components/
    layout/            Navigation, footer, and site-wide layout
    shared/            Reusable business-facing components
    ui/                Primitive interface components
  config/              Site and navigation configuration
  features/
    admin/              Admin dashboard feature
    booking/
      components/       Trip form, itinerary planner, and summary UI
      lib/              Distance and pricing logic
      types/            Booking-specific types
    destinations/       Destination content and UI
    fleet/              Driver and vehicle features
    packages/           Ready-made tour packages
  lib/
    email/ maps/ payments/ supabase/
  types/                Shared application types
supabase/
  migrations/           Database schema migrations
  seed/                 Development seed data
tests/
  e2e/                  End-to-end tests
  unit/                 Unit tests
```

The booking feature is separated from presentation and integrations so the
itinerary and pricing rules can be tested independently. The admin, fleet,
destinations, and packages have their own feature areas. Add implementation files
as each feature is started.
