Rails.application.routes.draw do
  # Authentication routes
  resource :session
  resources :passwords, param: :token

  # Galaxy Game feature routes
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"
  get "wormholes", to: "wormholes#index"
  get "admin", to: "admin#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
