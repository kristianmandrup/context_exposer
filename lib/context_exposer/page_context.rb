module ContextExposer
  class PageContext
    include Singleton

    attr_accessor :ctx

    def configure ctx, page = nil
      self.ctx = ctx
      self.page = page if page
    end

    def ctx= ctx
      unless ctx.kind_of? ContextExposer::ViewContext
        raise ArgumentErorr, "Must be a kind of ContextExposer::ViewContext, was: #{ctx}"
      end
      @ctx = ctx 
    end

    def page= page
      ctx.page = page
    end

    def page
      ctx.page if ctx
    end
  end
end