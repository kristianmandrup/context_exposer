module ContextExposer
  module Macros
    def context_exposer name = :base, options = {}
      self.send :include, "ContextExposer::#{name.to_s.camelize}Controller".constantize
      
      integrates_with [options[:with]].flatten if options[:with]
    end
  end
end