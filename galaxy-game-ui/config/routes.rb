Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  get "dashboard", to: "dashboard#index", as: :dashboard
  get   "about",     to: "landing#about"
  root  "landing#index"

  # Player views
  get "player/planetary", to: "player#planetary", as: :player_planetary

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
  end
end
