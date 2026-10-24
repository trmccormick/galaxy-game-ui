Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  get "dashboard", to: "dashboard#index", as: :dashboard
  root "landing#index"
end
