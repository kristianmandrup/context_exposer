require 'spec_helper'

ContextExposer.patch :decorates_before_rendering

class PostsController < ActionController::Base
  context_exposer :cached_resource
  decorates_before_render

  expose_resources :all
  
  def show
    configure_exposed_context
    render
  end

  def index
    configure_exposed_context
    render
  end

  protected

  def render *args
    __auto_decorate_exposed_ones_
  end

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
        subject   { ctx }
        let(:ctx) { controller.ctx }

        it "is an instance of ContextExposer::ViewContext" do
          expect(subject).to be_a ContextExposer::ViewContext
        end      

        it "defines a method :post" do
          expect(subject).to respond_to(:post)
        end      

        it "defines a method :posts" do
          expect(subject).to respond_to(:posts)
        end      

        it "defines a method :post_list" do
          expect(subject).to respond_to(:post_list)
        end      

        context 'post' do
          subject    { post }
          let(:post) { ctx.post }

          it "calling method :post returns 'My 1st post' " do
            expect(subject).to be_a PostDecorator
          end      

          it "calling method :post returns 'My 1st post' " do
            expect(subject.name).to eq @post1.name
          end      
        end

        context 'posts' do
          subject     { posts }
          let(:posts) { ctx.posts }

          before :each do        
            controller.index
          end

          it "calling method :posts returns all posts " do
            expect(subject).to eq [@post1, @post2]
          end    
        end

        context 'post_list' do
          subject         { post_list }
          let(:post_list) { ctx.post_list }

          before :each do        
            controller.index
          end

          it "calling method :posts_list returns all posts " do
            expect(subject).to eq [@post1, @post2]
          end      

          it "first posts is a PostDecorator " do
            expect(subject.first).to be_a PostDecorator
          end
        end
      end
    end
  end
end