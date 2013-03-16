ActiveSupport.on_load(:action_controller) do
  extend ContextExposer::Macros
end