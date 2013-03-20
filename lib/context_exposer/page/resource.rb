module ContextExposer
  class Page
    class Resource
      attr_accessor :name, :type, :controller

      def initialize name = nil, type = nil        
        self.name = name
        self.type = type if type
      end

      def type= type
        validate_type! type
        @type = type.to_sym
      end

      def name= name    
        @name = name.to_s    
        unless @type
          @type = calc_type 
        end
      end

      protected

      def page_context
        ContextExposer::PageContext.instance
      end

      def calc_type
        return nil if name.blank?
        name.to_s.plural? ? :list : :item
      end

      def validate_type! type
        unless valid_type? type
          raise ArgumentError, "type must be one of: #{valid_types}, was: #{type}"
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