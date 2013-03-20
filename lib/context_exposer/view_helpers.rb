module ContextExposer
  module ViewHelpers
    def render_ctx *args
      opts = args.last
      if opts.kind_of?(Hash) && opts[:locals]
        args.last[:locals].merge!(ctx: ContextExposer::PageContext.instance)
      end
      super *args
    end
  end
end