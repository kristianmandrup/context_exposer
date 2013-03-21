class AnimalsController < ApplicationController
  # cached resources with draper integration!
  context_exposer :cached_resource, with: :draper

  # basic expose methods for all resources
  expose_resources    :all

  # drape macros
  decorates_assigned  :animal, with: FancyAnimalDecorator  

  # expose all helper methods of draper on ctx
  context_expose :assigned

  def show   
  end

  def index
  end
end