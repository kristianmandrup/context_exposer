module ContextExposer
  module Integrations
    module Base
      extend ActiveSupport::Concern
      
      protected

      module ClassMethods
        def _exposure_filter keys, options = {}
          ::ContextExposer::Integrations::KeyFilter.new(keys, options).filter
        end
      end
    end
  end
end