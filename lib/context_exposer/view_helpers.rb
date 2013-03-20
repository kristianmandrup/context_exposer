module ContextExposer
  module ViewHelpers
    def render_ctx *args
      opts = args.last
      if opts.kind_of?(Hash) && opts[:locals]
        args.last[:locals].merge!(page_context: ContextExposer::PageContext.instance)
      end
      super *args
    end

    def ctx
      page_context.ctx
    end
  end
end