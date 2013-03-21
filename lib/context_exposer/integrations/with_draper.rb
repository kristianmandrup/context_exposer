require 'draper/decorates_assigned'

module ContextExposer::Integrations
  module WithDraper
    extend ActiveSupport::Concern
    extend Draper::DecoratesAssigned

    module ClassMethods
      def decorates_assigned(*variables)
        super
        variables.extract_options!
        @decorates_assigned_list = variables 
      end

      # expose all exposures exposed by decent_exposure to context
      def context_expose_assigned options = {}
        expose_keys = _decorates_assigned_list

        _exposure_filter(expose_keys, options).each do |exposure|
          exposed exposure do
            send(exposure)
          end
        end
      end
      alias_method :expose_assigned, :context_expose_assigned       

      protected

      def _decorates_assigned_list
        @decorates_assigned_list
      end
    end
  end
end