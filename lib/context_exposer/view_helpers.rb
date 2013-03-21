module ContextExposer
  module ViewHelpers
    # setup page_context delegators
    def ctx
      page_context.ctx
    end

    def the_page
      page_context.page
    end
  end
end