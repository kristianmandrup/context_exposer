module ContextExposer::BaseController
  extend ActiveSupport::Concern

  included do
    attr_reader :a

    before_filter :configure_exposed_context

    expose_context :context
  end

  def view_context    
    @view_context ||= build_view_context
  end
  alias_method :context, :view_context

  module ClassMethods
    def exposed name, &block
      exposure_storage[name.to_sym] = block
    end

    def view_context_class name
      define_method name do
        @view_context_class ||= name.kind_of?(Class) ? name : name.to_s.camelize.constantize
      end
    end

    protected

    def expose_context name
      return if exposed_view_context?
      if ActionController::Base.instance_methods.include?(name.to_sym)
        Kernel.warn "[WARNING] You are exposing the `#{name}` method, " \
          "which overrides an existing ActionController method of the same name. " \
          "Consider a different exposure name\n" \
          "#{caller.first}"
      end    
      helper_method name
      hide_action name
      @exposed_view_context = true
    end

    def exposed_view_context?
      @exposed_view_context ||= false
    end

    def exposure_storage
      exposure_hash[self.class.to_s] ||= {}
    end

    def exposure_hash
      @exposure_hash ||= {}
    end
  end

  def a_filter
    puts "a_filter"
    @a = true
  end

  # must be called after Controller is instantiated
  def configure_exposed_context
    return if configured_exposed_context?
    exposure_hash[self.class.to_s].each do |name, procedure|
      view_context.define_singleton_method name do 
        procedure.call
      end
    end
    @configured_exposed_context = true
  end

  def configured_exposed_context?
    @configured_exposed_context == true
  end

  protected

  # returns a ViewContext object 
  # view helpers can be exposed as singleton methods, dynamically be attached (see below)
  def build_view_context
    view_context_class.new self
  end

  def view_context_class
    @view_context_class ||= ContextExposer::ViewContext
  end
end
