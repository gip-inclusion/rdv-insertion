# AGENTS.md

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

Data model reference: `docs/SCHEMA_DATA.md` (tables, columns, statuses, data flows). Read it before changing a
model, an association, a migration, or a `FollowUp` status transition.

### Service Objects Pattern

In `app/services/`, a class is a service object when its `call` runs sequential steps that can each fail (`fail!`,
`call_service!`, external calls); `call` reads as that sequence of steps and is the service's only public method. A
class that computes and returns a value is a PORO in `app/models/`, like `UserArchivedStatus`.

Services inherit from `BaseService` (`app/services/base_service.rb`):
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

These conventions come from recurring review comments. When a change you have in mind departs from them, or from the
pattern that sibling files of the same kind follow, the convention wins.

### General

- Follow Basecamp/37signals Rails conventions: lean models and controllers, behavior isolated in concerns, domain
  logic in POROs.
- Prefer native framework solutions over custom implementations.
- Write comments only for code that is truly difficult to understand.
- Inline intermediate values used once, and keep guard clauses for cases that can actually occur.
- When a method becomes complex, extract well-named private methods for readability.
- Code, comments, and commit messages are attributed to the team alone, with no mention of AI assistants.
- Formatting (quotes, line length, etc.) is enforced by RuboCop and ESLint: run `make lint` before committing.
- Ruby method names describe what the method returns, without repeating their class's name
  (`Organisation#archived?`). A predicate method (ending in `?`) leaves its receiver and arguments unmodified.

### Controllers

- In controllers where every action checks the same policy query, the `set_*` method that loads the record also
  authorizes it (`authorize @organisation, :configure?`).
- Routes and controllers use the RESTful actions (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`). An
  operation outside them becomes a standard action on a dedicated resource: closing a follow-up is
  `FollowUps::ClosingsController#create`. Each action returns one kind of response whatever its params; a modal is
  rendered by the `new` or `edit` view of its resource.
- In controllers, views, and helpers, check that an agent is logged in with `logged_in?`, which also validates the
  session; read `current_agent` once the agent is known to be logged in.

### Data changes

- Rake tasks that delete or rewrite existing records support a dry run that logs the affected records and rolls back,
  as `Organisations::RgpdCleanup` does with `dry_run:`. Data migrations doing the same log the records they affect.

### Views

- Presentation logic (labels, CSS classes, formatting) lives in helpers; domain knowledge (status groups, business
  predicates) lives on the model, like `FollowUp::STATUSES_WITH_ACTION_REQUIRED`, and helpers and views call it.
- ERB partials (`_*.html.erb`) receive their data through locals passed to `render`; instance variables are read in
  the action's own template only.
- In ERB partials, strict locals declarations (`<%# locals: (...) %>`) are reserved for shared components, like
  `app/views/common/_image_upload_zone.html.erb`; a partial rendered from a single template takes plain locals.
- ERB templates indent by 2 spaces per nesting level, for HTML tags and ERB blocks alike.

### Stylesheets and JavaScript

- CSS class names describe appearance (color, size, emphasis) and carry their component's prefix
  (`.btn-primary--blue`, `.footer-bottom-list`). Colors come from the variables in
  `app/javascript/stylesheets/_variables.scss`. Styling lives in stylesheets: ERB elements get classes, with no
  `style` attribute.
- JavaScript classes in `app/javascript/` expose plain methods and properties (`isOpen()`), without `get`/`set`
  accessors.

## Testing

- RSpec with FactoryBot
- Request specs under `spec/requests/api/` generate the public API documentation via rswag
- Feature specs use Capybara with Selenium
- Controller behavior is tested through feature specs (`spec/features/`), or request specs (`spec/requests/`) for
  the API. `spec/controllers/` holds only cases that no feature spec covers.
- Specs exercise the unit through its public interface and assert on outcomes: return values, rendered pages, records
  written, services called. Framework declarations (`validates :name, presence: true`, associations) and private
  methods are covered through that public behavior, with no examples of their own.
- In specs, `subject` is declared unnamed (`subject { ... }`) and referenced as `subject`.
- In feature specs, waiting relies on Capybara's retrying matchers (`expect(page).to have_content(...)`,
  `have_css`), with no `sleep`.

## Pull Requests

Keep the description concise, in two sections:
- `## Contexte` — the why (problem, business or technical context)
- `## Implémentation` — the what, in short bullets

For a visible (UI) change, add a `## Preview` section with before/after screenshots.

## Environment

Requires:
- Ruby 4.0.1
- PostgreSQL >= 12
- Redis (for Sidekiq)
- Node.js + Yarn
- Running RDV-Solidarités instance for full functionality
