class Base
  module ClazzMethods
    extend ActiveSupport::Concern  

    module ClassMethods
      def model_name
        self.to_s
      end

      def find id
        list.first
      end

      def all
        list
      end

      protected

      def add obj
        list << obj
      end

      def list
        @list ||= []
      end
    end
  end
end