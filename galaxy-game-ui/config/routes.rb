Rails.application.routes.draw do
  # Authentication routes
  resource :session
  resources :passwords, param: :token

  # Galaxy Game feature routes
  root "landing#index"
  get "landing", to: "landing#index"
  post "landing/enter", to: "landing#enter_game"
  get "dashboard", to: "dashboard#index"
  get "wormholes", to: "wormholes#index"
  get "admin", to: "admin#index"
  
  # Catalog routes
  resources :blueprints, only: [:index, :show]
  resources :items, only: [:index, :show]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
