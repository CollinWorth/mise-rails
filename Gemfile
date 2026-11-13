source "https://rubygems.org"

ruby file: ".ruby-version"

# --- Rails and the web server ---
gem "rails", "~> 8.1.4", ">= 8.1.4.1"
gem "propshaft"
gem "puma", ">= 5.0"
# HTTP asset caching and compression in front of Puma, as in the production Dockerfile
gem "thruster", require: false
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# Windows does not include zoneinfo files
gem "tzinfo-data", platforms: %i[ windows jruby ]

# --- Database: Postgres in production, SQLite for local development and tests ---
gem "pg", "~> 1.5"
gem "sqlite3", ">= 2.1", group: %i[ development test ]

# --- Front end: Hotwire, Tailwind, and Phlex views built from RubyUI components ---
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "phlex-rails", "~> 2.4"
# refract (a Phlex dependency) still uses Prism::MissingNode, which Prism 2 removed
gem "prism", "< 2"
gem "tailwind_merge", "~> 1.5"
# Only used to copy components in (bin/rails g ruby_ui:component ...); the copies live in app/components/ruby_ui
gem "ruby_ui", "~> 1.6", group: :development

# --- Accounts, uploads and data ---
gem "bcrypt", "~> 3.1.7"
gem "image_processing", "~> 1.2"
# S3-compatible bucket for Active Storage in production
gem "aws-sdk-s3", "~> 1.0", require: false
gem "pagy", "~> 43.8"
# Parses ingredient quantities
gem "ingreedy", "~> 0.1.0"
# Reads the old Mongo dump (bin/rails import:mongo)
gem "bson", "~> 5.0", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false
  # Static analysis for security vulnerabilities
  gem "brakeman", require: false
  # Omakase Ruby styling
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.52"
  gem "minitest-mock", "~> 5.27"
  # Coverage report: COVERAGE=1 bin/rails test
  gem "simplecov", require: false
end
