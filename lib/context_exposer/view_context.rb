class ContextExposer::ViewContext
  attr_reader   :controller
  attr_accessor :page

  def initialize controller = nil, page = nil
    @controller = controller
    self.page   = page if page
  end

  def page= page
    validate_page! page
    @page = page
  end

  protected

  def validate_page! page
    raise ArgumentError, "Must be a kind of #{valid_page_class}, was: #{page}" unless valid_page? page
  end

  def valid_page? page
    page.kind_of? valid_page_class
  end

  def valid_page_class
    ContextExposer::Page
  end

  def define_singleton_method(name, &block)
    eigenclass = class<<self; self end
    eigenclass.class_eval {define_method name, block}
  end
end