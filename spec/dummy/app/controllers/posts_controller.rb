class PostsController < ApplicationController
  include ContextExposer::BaseController

  exposed(:post)  { posts.first }
  exposed(:posts) { ['Post 1', 'Post 2'] }

  def show    
  end

  def index
  end
end