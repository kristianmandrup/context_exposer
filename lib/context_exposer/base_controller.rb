require "context_exposer/integrations"

module ContextExposer::BaseController
  extend ActiveSupport::Concern
  include ContextExposer::Integrations::Base

  included do
    # before_filter :configure_exposed_context
    set_callback :process_action, :before, :configure_exposed_context

    set_callback :process_action, :after,  :save_exposed_context

    expose_context :ctx
  end

  def view_ctx
    @view_ctx ||= build_view_ctx
  end
  alias_method :ctx, :view_ctx

  module ClassMethods
    def normalized_resource_name
      self.to_s.demodulize.sub(/Controller$/, '').underscore.singularize
    end

    def exposed name, options = {}, &block
      _exposure_storage[name.to_sym] = {options: options, proc: block}
    end

    def expose_cached name, options = {}, &block
      exposed name, options.merge(cached: true), &block
    end

    def view_ctx_class name
      define_method :view_ctx_class do
        @view_ctx_class ||= name.kind_of?(Class) ? name : name.to_s.camelize.constantize
      end
    end

    def base_list_actions
      [:index]
    end

    def base_item_actions
      [:show, :new, :edit]
    end

    def list_actions *names
      return if names.blank?
      names = names.flatten.map(&:to_sym)
      (class << self; end).define_method :list_actions do
        names | base_list_actions
      end
    end

    def item_actions *names
      return if names.blank?
      names = names.flatten.map(&:to_sym)
      (class << self; end).define_method :item_actions do
        names | base_item_actions
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

    def _exposure_storage
      _exposure_hash[self.to_s] ||= {}
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

    def _exposure_hash
      @_exposure_hash ||= {}
    end    
  end

  # must be called after Controller is instantiated
  def configure_exposed_context
    return if configured_exposed_context?
    clazz = self.class
    exposed_methods = clazz.send(:_exposure_hash)[clazz.to_s] || []
    exposed_methods.each do |name, obj|
      options = obj[:options] || {}
      options[:cached] ? _add_cached_ctx_method(obj, name) : _add_ctx_method(obj, name)
    end
    @configured_exposed_context = true
  end

  def save_exposed_context
    ContextExposer::PageContext.instance.configure ctx, page_obj
  end

  def page_obj
    @page ||= build_page_obj
  end

  # TODO: cleanup!
  def build_page_obj
    return @page if @page
    @page = ContextExposer::Page.instance
    @page.clear!
    clazz = self.class

    # single or list resource ?
    @page.resource.type = calc_resource_type if calc_resource_type

    # also attempts to auto-caluclate resource.type if not set
    @page.resource.name = if clazz.respond_to?(:normalized_resource_name, true)
      clazz.normalized_resource_name 
    else
      clazz.resource_name if clazz.respond_to?(:resource_name, true)
    end

    @page.controller = self

    @page.name = if respond_to?(:page_name, true)
       page_name 
    else
      @page_name if @page_name
    end

    @page
  end

  def calc_resource_type
    return @resource_type if @resource_type
    clazz = self.class

    if clazz.respond_to?(:list_actions, true) && !clazz.list_actions.blank?
      resource_type = :list if clazz.list_actions[action_name.to_sym]
    end

    if !resource_type && clazz.respond_to?(:item_actions, true) && !clazz.item_actions.blank?
      resource_type = :item if clazz.item_actions[action_name.to_sym] 
    end
    @resource_type = resource_type
  end    

  def configured_exposed_context?
    @configured_exposed_context == true
  end

  protected

  def _add_ctx_method obj, name
    this = self    
    proc = obj[:proc]
    inst_var_name = "@#{name}"

    view_ctx.send :define_singleton_method, name do
      this.instance_eval(&proc)
    end
  end

  def _add_cached_ctx_method obj, name
    this = self
    options = obj[:options]
    proc = obj[:proc]
    inst_var_name = "@#{name}"

    view_ctx.send :define_singleton_method, name do
      old_val = instance_variable_get inst_var_name
      return old_val if old_val

      val = this.instance_eval(&proc)
      instance_variable_set inst_var_name, val
      val
    end
  end

  # returns a ViewContext object 
  # view helpers can be exposed as singleton methods, dynamically be attached (see below)
  def build_view_ctx
    view_ctx_class.new self
  end

  def view_ctx_class
    @view_ctx_class ||= ContextExposer::ViewContext
  end
end
