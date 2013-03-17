module ContextExposer
  module Macros
    def context_exposer name = :base, options = {}
      self.send :include, "ContextExposer::#{name.to_s.camelize}Controller".constantize
      
      integrates_with [options[:with]].flatten if options[:with]
    end

    def decorates_before_rendering
      unless defined? ::DecoratesBeforeRendering
        raise "DecoratesBeforeRendering not found, please include the gem 'decorates_before_rendering'"
      end
      self.send :include, DecoratesBeforeRendering
    end
    alias_method :decorates_before_render, :decorates_before_rendering
  end
end