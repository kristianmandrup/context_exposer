module PluralTester
  def singular?
    self.pluralize.singularize == self
  end

  def plural?
    self.singularize.pluralize == self
  end
end

class String
  include PluralTester
end