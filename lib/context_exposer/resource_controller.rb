module ContextExposer::ResourceController
  extend ActiveSupport::Concern
  include ContextExposer::BaseController

  included do
    expose_resources
  end

  protected

  module ClassMethods
    def expose_resources *types
      types = types.flatten
      types = types.empty? ? [:all] : types

      unless expose_resource_method? :one, types
        _exposing(_normalized_resource_name.singularize)  { find_single_resource    }
      end

      unless expose_resource_method? :many, types
        _exposing(_normalized_resource_name.pluralize)    { find_all_resources      }
      end

      unless expose_resource_method? :list, types
        _exposing(_normalized_resource_list)              { find_all_resources.to_a }
      end
    end    

    def expose_resource_method? type, types
      ([type, :all] & types).empty?
    end
  end  


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
      _normalized_resource_name.singularize + '_list'
    end

    def _normalized_resource_name
      self.to_s.demodulize.sub(/Controller$/, '').underscore
    end
  end
end

