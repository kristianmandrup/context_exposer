source 'https://rubygems.org'

# Specify your gem's dependencies in context_exposer.gemspec
gemspec

gem 'rails', '>= 3.1'
gem "rspec",       '>= 2.0', group: [:test, :development]
gem "rspec-rails", '>= 2.0', group: [:test, :development]
gem 'pry',         group: [:development]

group :test do
  gem 'capybara', '>= 2.0'
  gem 'spork-rails', '>= 3.0'

  gem 'draper', '>= 1.1.0'
  gem 'decent_exposure', '>= 2.0.0'
  gem 'decorates_before_rendering', github: 'ohwillie/decorates_before_rendering'

  # gem 'factory_girl_rails', '>= 3.0'
  # gem 'database_cleaner', '>= 0.7'
end