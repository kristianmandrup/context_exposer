module ContextExposer::ResourceController
  extend ActiveSupport::Concern
  include ContextExposer::BaseController

  included do
    _exposing(_normalized_resource_name.singularize)  { find_single_resource    }
    _exposing(_normalized_resource_name.pluralize)    { find_all_resources      }
    _exposing(_normalized_resource_list)              { find_all_resources.to_a }
  end

  protected

  def resource_id
    params[:id]
  end

  def find_single_resource
    self.class._the_resource.find resource_id
  end

  def find_all_resources
    self.class._the_resource.all
  end

  module ClassMethods
    # for use in ResourceController
    def _exposing name, options = {}, &block
      exposed name, options, &block
    end
    
    def _the_resource
      clazz_name = self.to_s.sub(/Controller$/, '').singularize
      clazz_name.constantize
    rescue NameError => e
      raise "Resource #{clazz_name} is not defined. #{e}"
    end

    def _normalized_resource_list
      _normalized_resource_name.pluralize + '_list'
    end

    def _normalized_resource_name
      self.to_s.demodulize.sub(/Controller$/, '').underscore
    end
  end
end

