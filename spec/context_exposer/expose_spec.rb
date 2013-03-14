require 'context_exposer'
require 'action_controller'

class MyController < ActionController::Base
  include ContextExposer::BaseController
  
  exposed(:bird) { "Bird" }

  def post
  end

  def params; end
end

describe ContextExposer::BaseController do

  describe "controller" do
    subject { controller }

    let(:controller) { MyController.new }

    # run action post
    before :each do
      controller.post
    end

    it 'defines :post as an action_method' do
      expect(subject.action_methods).to include('post')
    end

    it "defines a method context" do
      expect(subject).to respond_to(:context)
    end

    it "exposes the context to the view layer as a helper" do
      expect(subject._helper_methods).to include(:context)
    end

    it "prevents the context method from being routable" do
      expect(subject.hidden_actions).to include("context")
    end

    it 'ran before filter :a_filter' do
      expect(subject.a).to_not be_nil
    end

    it 'configured exposed context' do
      expect(subject.configured_exposed_context?).to be_true
    end

    context 'context' do
      subject { controller.context }

      it "is an instance of ContextExposer::ViewContext" do
        expect(subject).to be_a ContextExposer::ViewContext
      end      

      it "defined a method :bird" do
        expect(subject).to respond_to(:bird)
      end      

      it "calling method :bird returns 'Bird' " do
        expect(subject.bird).to eq "Bird"
      end      
    end
  end
end