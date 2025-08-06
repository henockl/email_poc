# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails 8.0.2 application implementing a newsletter email system. The application includes newsletter creation/management, subscriber management, bulk email sending, email tracking (Ahoy Email), and unsubscribe functionality (Mailkick). Content is written in Markdown and rendered with Marksmith.

## Development Commands

### Server Management
```bash
bin/rails server                    # Start development server on localhost:3000
bin/rails server -p 4000           # Start on custom port
```

### Database Operations
```bash
bin/rails db:migrate                # Run pending migrations
bin/rails db:rollback              # Rollback last migration
bin/rails db:seed                  # Load seed data
bin/rails db:reset                 # Drop, create, migrate, and seed
```

### Testing
```bash
bin/rails test                     # Run all tests
bin/rails test test/models/         # Run model tests only
bin/rails test test/controllers/    # Run controller tests only
bin/rails test:system              # Run system tests with Capybara
bin/rails test test/path/to/file.rb # Run specific test file
```

### Code Quality
```bash
bin/rubocop                        # Run RuboCop linter
bin/rubocop -a                     # Auto-fix safe offenses
brakeman                           # Security vulnerability scan
```

### Rails Generators (for email POC development)
```bash
bin/rails generate mailer UserMailer welcome_email  # Generate mailer
bin/rails generate model User email:string          # Generate user model
bin/rails generate controller Emails index show     # Generate controller
```

### Background Jobs & Queues
```bash
bin/rails solid_queue:start        # Start Solid Queue job processor
bin/rails jobs:work                # Process jobs (alternative)
```

## Architecture Overview

### Framework Stack
- **Rails 8.0.2** with modern defaults and Hotwire (Turbo + Stimulus)
- **SQLite3** database for development/test (production needs configuration)
- **Solid Queue/Cache/Cable** - Rails 8.0's database-backed adapters
- **Propshaft** modern asset pipeline with **Import Maps** for JavaScript

### Email Infrastructure
- **ActionMailer** with ApplicationMailer base class and NewsletterMailer
- **Marksmith** for Markdown-to-HTML rendering in newsletters
- **Ahoy Email** for email tracking (opens, clicks)
- **Mailkick** for unsubscribe/opt-out management
- **Bulk email sending** with BCC batching (50 recipients per batch)
- **SendNewsletterJob** for background newsletter processing
- Development email delivery disabled by default
- Production SMTP configuration available but commented in `config/environments/production.rb`

### Key Configuration Files
- `config/application.rb` - Main app configuration with Rails 8.0 defaults
- `config/environments/` - Environment-specific settings including email delivery
- `config/initializers/` - Framework initializers including Marksmith, Ahoy Email, Simple Form
- `config/routes.rb` - Newsletter and subscriber resource routes with root to newsletters#index

### Testing Structure
- **Minitest** framework with parallel execution enabled
- **Capybara + Selenium** for system tests
- Standard Rails test directories: `test/controllers/`, `test/models/`, `test/mailers/`, `test/system/`
- Fixtures in `test/fixtures/` for test data

### Deployment & Production
- **Docker** multi-stage production build with **Thruster** HTTP acceleration
- **Kamal** deployment configuration in `.kamal/` directory
- **Jemalloc** memory optimization in production container
- SSL enforcement and security headers configured for production

## Development Notes

### Current State
The newsletter email system is fully implemented with:
- **Newsletter model** with validation, publishing workflow, and edit restrictions
- **Subscriber model** with email validation and Mailkick integration for opt-outs
- **NewsletterMailer** with bulk sending capability and HTML sanitization
- **SendNewsletterJob** for background processing of scheduled newsletters
- **Web interface** for managing newsletters and subscribers with Simple Form
- **Email tracking** via Ahoy Email for opens/clicks analytics

### Rails 8.0 Modern Patterns
- Modern browser requirement enforced (`allow_browser versions: :modern`)
- Database-backed solid adapters for caching, jobs, and ActionCable
- Hotwire for SPA-like behavior without complex JavaScript builds
- Import Maps instead of traditional asset bundling

### Email System Architecture
- **Newsletter publishing workflow**: Draft → Published → Sent (with edit restrictions)
- **Bulk email sending**: BCC batching (50 recipients) with error handling and logging
- **Markdown content**: Newsletters written in Markdown, rendered to sanitized HTML
- **Email tracking**: Ahoy Email tracks opens/clicks with unique message IDs
- **Unsubscribe management**: Mailkick handles opt-outs per subscriber
- **Background processing**: SendNewsletterJob processes scheduled newsletters
- **HTML sanitization**: Newsletter content sanitized for email safety
- Production SMTP settings need configuration in `config/environments/production.rb`

### Security & Performance
- **Brakeman** security scanning available in development
- **Bootsnap** for faster boot times
- SSL and security headers configured for production
- Modern Rails security defaults active