class ContextExposer::ViewContext
  attr_reader :controller

  def initialize controller = nil
    @controller = controller
  end

  protected

  def define_singleton_method(name, &block)
    eigenclass = class<<self; self end
    eigenclass.class_eval {define_method name, block}
  end 

  delegate :lookup_context, to: :controller   
end