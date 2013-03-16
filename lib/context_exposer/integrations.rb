module ContextExposer
  module Integrations
  end
end

%w{base key_filter with_decent_exposure with_decorates_before with_instance_vars}.each do |name|
  require "context_exposer/integrations/#{name}"
end