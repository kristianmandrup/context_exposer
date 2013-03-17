class PostsController < ApplicationController
  include ContextExposer::BaseController

  exposed(:post)  { Post.find 1 }
  exposed(:posts) { Post.all }

  def show   
  end

  def index
  end
end