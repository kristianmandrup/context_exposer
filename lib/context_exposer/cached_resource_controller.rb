module ContextExposer::CachedResourceController
  extend ActiveSupport::Concern
  include ContextExposer::ResourceController

  module ClassMethods
    def _exposing name, options = {}, &block
      expose_cached name, options, &block
    end
  end
end
