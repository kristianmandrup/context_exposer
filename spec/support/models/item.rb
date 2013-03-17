class Item < Base
  def initialize name
    super
  end

  def decorator contrl
    "#{model_name}CustomDecorator"
  end
end