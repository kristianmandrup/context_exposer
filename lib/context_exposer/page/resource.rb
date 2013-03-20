module ContextExposer
  class Page
    class Resource
      attr_accessor :name, :type

      def initialize name = nil, type = nil        
      end

      def type= type
        validate_type! type
        @type = type.to_sym
      end

      def name= name        
        @type = name.plural? ? :list : :item unless @type
      end

      def validate_type! type
        unless valid_type? type
          raise ArgumentError, "type must be one of: #{valid_types}"
        end
      end

      def valid_type? type
        valid_types.include? type.to_sym
      end

      def valid_types
        [:list, :item]
      end
    end
  end
end