# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RDV-Insertion is a French public service application developed by beta.gouv.fr. It facilitates RSA (welfare) appointment management by interfacing with RDV-Solidarités (a separate appointment scheduling application).

**Key distinction:**
- **RDV-Solidarités**: Handles appointment logic (créneaux, plages d'ouvertures, agendas)
- **RDV-Insertion**: Handles follow-ups of appointments within motif categories, and invitations to take appointments

Both are Ruby on Rails applications. RDV-Insertion requires a running RDV-Solidarités instance to function properly.

## Common Commands

```bash
# Setup
make install          # Run bin/setup (install gems, packages, create DB)

# Development
make run              # Start app with foreman (web, jobs, webpack)

# Testing
make test                                    # Run all tests
bundle exec rspec path/to/spec.rb            # Run single test file
bundle exec rspec path/to/spec.rb:42         # Run specific test at line

# Linting
make lint             # Run all linters (rubocop + eslint)
make lint_rubocop     # Ruby linter only
make lint_eslint      # JavaScript linter only
make autocorrect      # Auto-fix rubocop issues

# API Documentation
make rswag            # Generate OpenAPI docs from request specs
                      # Docs visible at /api-docs

# Database schema diagram
rake erd              # Regenerate domain_model.png in docs/
```

## Architecture

### Domain Model

**Core entities:**
- `User` - People needing to take appointments (RSA beneficiaries)
- `Organisation` - Structures managing users (e.g., departmental councils)
- `Department` - French departments containing organisations
- `FollowUp` - Tracks a user's progress within a motif category
- `Invitation` - Sent to users to prompt them to book appointments
- `Participation` - Links users to RDVs (appointments)
- `MotifCategory` - Categories of appointment types (orientation, accompagnement, etc.)
- `CategoryConfiguration` - Organisation-specific settings for a motif category

**Relationships:**
- Users belong to Organisations through `UsersOrganisation`
- Users have FollowUps for each MotifCategory they're tracked in
- Invitations are sent for FollowUps to prompt appointment booking
- Participations track actual RDV attendance and status

### Service Objects Pattern

All services inherit from `BaseService` (`app/services/base_service.rb`):
- Implement a single `call` method
- Called via `ServiceClass.call(**kwargs)`
- Return an `OpenStruct` responding to `success?` and `failure?`
- Access result via `result` instance variable to attach data
- Use `fail!(message)` to abort with error
- Use `call_service!(ServiceClass, **)` to chain services

### RDV-Solidarités Integration

Two-way sync between apps:
- RDV-I → RDV-S: Synchronous API calls via `RdvSolidaritesClient` within transactions
- RDV-S → RDV-I: Webhooks received at `/rdv_solidarites_webhooks`, processed async via jobs

Shared attributes between apps are defined in model constants (e.g., `SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES`)

### Background Jobs

Uses Sidekiq for job processing. Key patterns:
- `LockedJobs`: Advisory lock to prevent parallel execution on the same resource
- `LockedAndOrderedJobs`: Lock + timestamp check to ignore outdated jobs (useful for webhooks arriving out of order)

### Frontend

- Uses Hotwire/Turbo for dynamic updates
- DSFR (Design System de l'État français) for UI components
- Stimulus for JavaScript controllers

## Code Conventions

- Always use double quotes for strings
- Use concerns extensively to isolate behavior (Basecamp style)
- Use POROs for domain logic (Basecamp style)
- Service objects for procedural logic with success/failure states (sequential actions, external calls)
- Keep models and controllers lean
- Follow Basecamp/37signals Rails conventions
- Max line length: 120 characters
- Comments only for code that is truly difficult to understand (avoid unnecessary comments)
- Do not reference AI tools (Claude, Cursor, etc.) in code, comments, or commits
- Avoid unnecessary guard clauses and intermediate variable assignments
- When a method becomes complex, extract into well-named private methods for readability
- Prefer native framework solutions over custom implementations

## Testing

- RSpec with FactoryBot
- Request specs generate API documentation via rswag
- Feature specs use Capybara with Selenium

## Environment

Requires:
- Ruby 4.0.1
- PostgreSQL >= 12
- Redis (for Sidekiq)
- Node.js + Yarn
- Running RDV-Solidarités instance for full functionality
