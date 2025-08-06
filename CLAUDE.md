# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails 8.0.2 application serving as a proof-of-concept for email functionality. The codebase is currently in a fresh Rails state with minimal customization, ready for email-related feature development.

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
- **ActionMailer** with ApplicationMailer base class
- Development email delivery disabled by default
- Production SMTP configuration available but commented in `config/environments/production.rb`
- Mailer views in `app/views/layouts/mailer.html.erb` and `mailer.text.erb`

### Key Configuration Files
- `config/application.rb` - Main app configuration with Rails 8.0 defaults
- `config/environments/` - Environment-specific settings including email delivery
- `config/initializers/` - Framework initializers (mostly defaults)
- `config/routes.rb` - Currently only health check route defined

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
This is a freshly generated Rails application with no custom business logic implemented yet. The email POC functionality needs to be built from scratch, including:
- Custom mailer classes and email templates
- Email-related models and controllers
- User authentication (bcrypt gem available but commented)
- Email queue and delivery management interfaces

### Rails 8.0 Modern Patterns
- Modern browser requirement enforced (`allow_browser versions: :modern`)
- Database-backed solid adapters for caching, jobs, and ActionCable
- Hotwire for SPA-like behavior without complex JavaScript builds
- Import Maps instead of traditional asset bundling

### Email Development Considerations
- Production SMTP settings need configuration in `config/environments/production.rb`
- Default mailer sender is "from@example.com" and should be customized
- Consider adding email templates for common use cases (welcome, notifications, etc.)
- Background job processing with Solid Queue for reliable email delivery

### Security & Performance
- **Brakeman** security scanning available in development
- **Bootsnap** for faster boot times
- SSL and security headers configured for production
- Modern Rails security defaults active