module ContextExposer
  module Integrations
    module Base
      protected

      def _exposure_filter keys, options = {}
        ::ContextExposer::Integrations::KeyFilter.new(keys, options).filter
      end
    end
  end
end