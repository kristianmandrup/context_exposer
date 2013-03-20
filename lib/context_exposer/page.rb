require 'context_exposer/page/resource'

module ContextExposer
  class Page
    include Singleton

    attr_accessor :name, :id, :action, :controller_name, :type, :resource

    def configure name = nil, options = {}
      self.name = name
      self.type = options[:type]
      self.resource.name = options[:resource_name]
      self.resource.type = options[:resource_type]
    end

    # action= 'show', resource.name = 'post' and resource.type = :item
    #   show_post_item 
    # action= 'manage', resource.name = 'post' and resource.type = :list
    #   manage_post_list
    def name
      @name ||= [action, resource.name, resource.type].compact.join('_')
    end

    def controller= controller
      # @id     = ActionController::Routing::Routes.recognize_path(controller.request.url)[:id]
      @action = controller.action_name
      @controller_name = controller.controller_name    
    end

    def resource
      @resource ||= Resource.new
    end

    def map?
      false
    end
  end
end