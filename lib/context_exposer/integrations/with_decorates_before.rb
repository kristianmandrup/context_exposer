module ContextExposer::Integrations
  module WithDecoratesBefore
    extend ActiveSupport::Concern

    # expose all exposures exposed by decent_exposure to context
    def context_expose_decorated_instance_vars options = {}
      coll_decorates  = __decorates_collection__[0..-1]
      basic_decorates = __decorates__[0..-1]

      all_decorates  = case options[:for]
      when :collection
        coll_decorates
      when :non_collection
        basic_decorates
      else
        coll_decorates + basic_decorates
      end
      
      expose_keys     = all_decorates.map {|v| v[1..-1]}

      _exposure_filter(keys, options).each do |exposure|
        exposed exposure do
          send("@#{exposure}")
        end
      end
    end
    alias_method :expose_decorated_instance_vars, :context_expose_decorated_instance_vars
  end
end