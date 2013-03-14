class ContextExposer::ViewContext
  attr_reader :controller

  def initialize controller
    @controller = controller
  end

  def define_singleton_method(name, &block)
    eigenclass = class<<self; self end
    eigenclass.class_eval {define_method name, block}
  end    
end