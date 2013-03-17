class Base
  include ClazzMethods

  attr_accessor :name

  def initialize name
    @name = name    
    self.class.send :add, self
  end

  def to_s
    name
  end

  def model_name
    self.class.to_s
  end
end