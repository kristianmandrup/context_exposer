require 'spec_helper'

class MyController < ActionController::Base
  include ContextExposer::BaseController
  
  exposed(:bird) { "Bird" }

  # since: extend DecentExposure::Exposure
  def self._exposures
    {decent: 'hi', hello: 'yo!'}
  end  

  integrate_with :decent_exposure

  context_expose :decently, except: %w{hello}

  def show
    configure_exposed_context
  end

  protected
end

class MyCoolController < ActionController::Base
  context_exposer :base
  
  exposed(:coolness) { "MegaCool" }

  view_ctx_class :mega_cool_view_context

  def show
    configure_exposed_context
  end

  protected

  def params; end  
end

class MegaCoolViewContext < ContextExposer::ViewContext
  def initialize controller
    super
  end

  def power_of number
    number * number
  end
end

describe ContextExposer::BaseController do

  describe "controller" do
    subject { controller }

    let(:controller) { MyController.new }

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

    it "prevents the context method from being routable" do
      expect(subject.hidden_actions).to include("ctx")
    end

    it 'configured exposed context' do
      expect(subject.configured_exposed_context?).to be_true
    end

    context 'context' do
      subject { controller.ctx }

      it "is an instance of ContextExposer::ViewContext" do
        expect(subject).to be_a ContextExposer::ViewContext
      end      

      it "defines a method :bird" do
        expect(subject).to respond_to(:bird)
      end      

      it "defines a method :decent" do
        expect(subject).to respond_to(:decent)
      end      

      it "does not defines a decent method :hello" do
        expect(subject).to_not respond_to(:hello)
      end      

      it "calling method :bird returns 'Bird' " do
        expect(subject.bird).to eq "Bird"
      end      
    end
  end

  describe 'MyCoolController' do
    subject { controller }

    let(:controller) { MyCoolController.new }

    # run action post
    before :each do
      controller.show
    end

    context 'context' do
      subject { controller.ctx }

      it "inherits from ContextExposer::ViewContext" do
        expect(subject).to be_a ContextExposer::ViewContext
      end      

      it "is an instance of MegaCoolViewContext" do
        expect(subject).to be_a MegaCoolViewContext
      end      

      it "has reference to controller" do
        expect(subject.controller).to eq controller
      end      

      it "defines a method :coolness" do
        expect(subject).to respond_to(:coolness)
      end      

      it "calling method :coolness returns 'MegaCool' " do
        expect(subject.coolness).to eq "MegaCool"
      end      

      it "defines a method :power_of" do
        expect(subject).to respond_to(:power_of)
      end      

      it "calling method :power_of(2) returns 4" do
        expect(subject.power_of 2).to eq 4
      end      
    end    
  end
end