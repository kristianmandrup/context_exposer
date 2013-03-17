module ContextExposer::CachedResourceController
  extend ActiveSupport::Concern
  include ContextExposer::ResourceController

  def self._exposing name, options = {}, &block
    expose_cached name, options, &block
  end  
end
