source 'https://rubygems.org'

# Specify your gem's dependencies in context_exposer.gemspec
gemspec

gem 'rails', '>= 3.1'

group :test, :development do
  gem "rspec",       '>= 2.10'
  gem "rspec-rails", '>= 2.0'
end

group :test do
  # to test gem integrations 
  gem 'draper',                       '>= 1.1.0', github: 'drapergem/draper'
  gem 'decent_exposure',              '>= 2.0.0'
  gem 'decorates_before_rendering',   '~> 0.0.3'

  # for Dummy app test
  gem 'spork-rails',                  '>= 3.0'
  gem 'capybara',                     '>= 2.0'

  # gem 'factory_girl_rails',           '>= 3.0'
  # gem 'database_cleaner',             '>= 0.7'
end

group :development do
  gem 'pry'
end