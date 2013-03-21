class FancyAnimalDecorator < Draper::Decorator
  delegate_all

  def fancy
    "A very fancy #{name}"
  end
end
