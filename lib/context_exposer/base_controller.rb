require "context_exposer/integrations"

module ContextExposer::BaseController
  extend ActiveSupport::Concern
  include ContextExposer::Integrations::Base

  included do
    # before_filter :configure_exposed_context
    set_callback :process_action, :before, :configure_exposed_context

    expose_context :ctx
  end

  def view_ctx
    @view_ctx ||= build_view_ctx
  end
  alias_method :ctx, :view_ctx

  module ClassMethods
    def exposed name, &block
      # puts "store: #{name} in hash storage for class #{self}"
      _exposure_storage[name.to_sym] = block
    end

    def view_ctx_class name
      define_method :view_ctx_class do
        @view_ctx_class ||= name.kind_of?(Class) ? name : name.to_s.camelize.constantize
      end
    end

    def integrate_with *names
      names.flatten.compact.each do |name|
        self.send :include, "ContextExposer::Integrations::With#{name.to_s.camelize}".constantize
      end
    end
    alias_method :integrates_with, :integrate_with

    def context_expose name, options = {}
      send "context_expose_#{name}", options
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
      @_exposed_view_context = true
    end

    def exposed_view_context?
      @_exposed_view_context == true
    end

    def _exposure_storage
      _exposure_hash[self.to_s] ||= {}
    end

    def _exposure_hash
      @_exposure_hash ||= {}
    end
  end

  # must be called after Controller is instantiated
  def configure_exposed_context
    return if configured_exposed_context?
    clazz = self.class
    exposed_methods = clazz.send(:_exposure_hash)[clazz.to_s] || []
    exposed_methods.each do |name, procedure|
      this = self
      view_ctx.send :define_singleton_method, name do 
        this.instance_eval(&procedure)
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
  def build_view_ctx
    view_ctx_class.new self
  end

  def view_ctx_class
    @view_ctx_class ||= ContextExposer::ViewContext
  end
end
