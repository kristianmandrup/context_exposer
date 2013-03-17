Dummy::Application.routes.draw do
  resources :posts, only: [:show, :index]
  resources :items, only: [:show, :index]
end
