require 'rubygems'
require 'bundler/setup'

require "rspec"

require 'decent_exposure'
require 'decorates_before_rendering'

require 'context_exposer'

require 'action_controller'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/models/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].each { |f| require f }  
Dir["#{File.dirname(__FILE__)}/support/decorators/*.rb"].each { |f| require f }  

RSpec.configure do |config|
  # some (optional) config here
end