module ContextExposer
  module Macros
    def context_exposer name = :base
      self.send :include, "ContextExposer::#{name.to_s.camelize}Controller"
    end
  end
end