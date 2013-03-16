module ContextExposer::Integrations
  module WithInstanceVars
    extend ActiveSupport::Concern

    # expose all exposures exposed by decent_exposure to context
    def context_expose_instance_vars options = {}
      expose_keys = self.instance_variables.map {|v| v[1..-1]}

      _exposure_filter(expose_keys, options).each do |exposure|
        exposed exposure do
          send("@#{exposure}")
        end
      end
    end
    alias_method :expose_instance_vars, :context_expose_instance_vars
  end
end