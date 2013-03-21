require 'context_exposer/page/resource'

module ContextExposer
  class Page
    include Singleton

    attr_accessor :name, :id, :action, :mode, :controller_name, :type, :resource

    def configure name = nil, options = {}
      self.name = name
      self.type = options[:type]
      self.resource.name = options[:resource_name]
      self.resource.type = options[:resource_type]
    end

    def clear!
      inst_variables.each do |inst_var|
        var = inst_var.to_s.sub('@', '')
        self.send("#{var}=", nil)
      end
    end

    # action= 'show', resource.name = 'post' and resource.type = :item
    #   show_post_item 
    # action= 'manage', resource.name = 'post' and resource.type = :list
    #   manage_post_list
    def name
      @name ||= [action, resource.name, resource.type].compact.map(&:to_s).join('_').underscore
    end

    def controller= controller
      @action = controller.action_name
      @controller_name = controller.controller_name    
    end

    def resource
      @resource ||= Resource.new
    end

    def map?
      false
    end

    protected

    def inst_variables
      [:name, :id, :action, :mode, :controller_name, :type, :resource]
    end
  end
end