class ItemDecorator < BaseDecorator
  def nice_name
    "A very nice #{name}"
  end
end

class ItemCustomDecorator < ItemDecorator
  def custom
    "#{name} was customized :)"
  end
end