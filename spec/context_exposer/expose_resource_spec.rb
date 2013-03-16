require 'context_exposer'
# require 'rails'
require 'action_controller'

class Post
  attr_accessor :name

  def initialize name
    @name = name
    Post.add self
  end

  def self.find id
    list.first
  end

  def self.all
    Post.list
  end

  protected

  def self.add post
    list << post
  end

  def self.list
    @list ||= []
  end
end

class PostsController < ActionController::Base
  include ContextExposer::ResourceController
  
  def show
    configure_exposed_context
  end

  def index
  end

  protected

  def params
    {id: 1}
  end
end

describe ContextExposer::ResourceController do
  describe "controller" do
    subject { controller }

    let(:controller) { PostsController.new }

    before :all do
      @post1 = Post.new 'My 1st post'
      @post2 = Post.new 'My 2nd post'
    end

    context 'show post' do
      # run action post
      before :each do        
        controller.show
      end

      it 'defines :show as an action_method' do
        expect(subject.action_methods).to include('show')
      end

      it "defines a method context" do
        expect(subject).to respond_to(:ctx)
      end

      it "exposes the context to the view layer as a helper" do
        expect(subject._helper_methods).to include(:ctx)
      end

      context 'context' do
        subject { controller.ctx }

        it "is an instance of ContextExposer::ViewContext" do
          expect(subject).to be_a ContextExposer::ViewContext
        end      

        it "defines a method :post" do
          expect(subject).to respond_to(:post)
        end      

        it "defines a method :posts" do
          expect(subject).to respond_to(:posts)
        end      

        it "calling method :post returns 'My 1st post' " do
          expect(subject.post.name).to eq @post1.name
        end      

        it "calling method :posts returns all posts " do
          expect(subject.posts).to eq [@post1, @post2]
        end      
      end
    end
  end
end