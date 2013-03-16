module ContextExposer::ResourceController
  extend ActiveSupport::Concern
  include ContextExposer::BaseController

  included do
    puts "included: #{_normalized_resource_name}"

    exposed(_normalized_resource_name.singularize) do
      find_single_resource
    end

    exposed(_normalized_resource_name.pluralize)    { find_all_resources }
    exposed(_normalized_resource_list)              { find_all_resources.to_a }
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

