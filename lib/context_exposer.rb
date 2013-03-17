require "context_exposer/version"

module ContextExposer
  def self.patch name
    case name.to_sym
    when :decorates_before_render
      require "context_exposer/patch/#{name}"
    else
      raise ArgumentError, "No patch defined for: #{name}. Try one of #{patches}"
    end
  end

  def self.patches
    [:decorates_before_render]
  end
end

require "active_support"
require "context_exposer/base_controller"
require "context_exposer/resource_controller"
require "context_exposer/cached_resource_controller"
require "context_exposer/view_context"
require "context_exposer/macros"
require "context_exposer/rails_config"
