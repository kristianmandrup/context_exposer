module ContextExposer::Integrations
  module WithDecentExposure
    extend ActiveSupport::Concern

    module ClassMethods
      # expose all exposures exposed by decent_exposure to context
      def context_expose_assigned *names
        options = names.extract_options!
        expose_keys = names
        expose_keys = _assigned.keys if expose_keys.empty? && respond_to? :_assigned
        return if expose_keys.blank?

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