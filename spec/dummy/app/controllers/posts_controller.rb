class PostsController < ApplicationController
  include ContextExposer::BaseController

  exposed(:post) { 'A post '}

  exposed(:posts) { ['A post ', 'Another post'] }

  def show    
  end

  def index
  end
end