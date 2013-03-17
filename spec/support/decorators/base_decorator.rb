class BaseDecorator
  attr_reader :obj

  def initialize obj = nil
    @obj = nil
  end

  def self.decorate obj
    self.new obj
  end

  def decorate obj
    @obj = obj
    self
  end

  def == other
    other == obj || other == self
  end

  delegate :name, :to_s, to: :obj
end