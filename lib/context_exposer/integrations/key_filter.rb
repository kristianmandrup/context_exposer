module ContextExposer
  module Integrations
    class KeyFilter
      attr_reader :keys, :options

      def initialize keys, options = {}
        @keys = keys || []
        @options = options
      end

      # expose all exposures exposed by decent_exposure to context
      def filter
        the_keys = keys - except
        only.empty? ? the_keys : the_keys.select {|k| only.include? k.to_sym } 
      end

      def except
        @except ||= symbolize_opts :except
      end

      def only
        @only ||= symbolize_opts :only
      end

      def symbolize_opts name 
        (options[name.to_sym] || {}).map(&:to_sym)
      end
    end
  end
end