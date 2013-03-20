require "context_exposer/version"

module ContextExposer
  def self.patch name
    case name.to_sym
    when :decorates_before_rendering
      require "context_exposer/patch/#{name}"
    else
      raise ArgumentError, "No patch defined for: #{name}. Try one of #{patches}"
    end
  end

  def self.patches
    [:decorates_before_rendering]
  end
end

require "active_support"
require "context_exposer/core_ext/string"
require "context_exposer/base_controller"
require "context_exposer/resource_controller"
require "context_exposer/cached_resource_controller"
require "context_exposer/view_context"
require "context_exposer/macros"
require "context_exposer/rails_config"

require 'singleton'
require "context_exposer/page_context"
require "context_exposer/page"
require "context_exposer/view_helpers"