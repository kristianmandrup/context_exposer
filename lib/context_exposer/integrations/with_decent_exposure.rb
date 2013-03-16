module ContextExposer::Integrations
  module WithDecentExposure
    extend ActiveSupport::Concern

    module ClassMethods
      # expose all exposures exposed by decent_exposure to context
      def context_expose_decently options = {}
        expose_keys = _exposures.keys

        _exposure_filter(expose_keys, options).each do |exposure|
          exposed exposure do
            send(exposure)
          end
        end
      end
      alias_method :expose_decently, :context_expose_decently       
    end
  end
end