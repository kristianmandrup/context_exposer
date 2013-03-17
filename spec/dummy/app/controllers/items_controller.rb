class ItemsController < ApplicationController
  decorates_before_render
  context_exposer :cached_resource

  def show   
  end

  def index
  end
end