Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  get "dashboard", to: "dashboard#index", as: :dashboard
  get "about", to: "landing#about"
  root "landing#index"

  # Player views
  get "player/planetary", to: "player#planetary", as: :player_planetary

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard

    get "ai_manager", to: "ai_manager#index", as: :ai_manager
    get "ai_manager/missions", to: "ai_manager#missions", as: :ai_manager_missions
    get "ai_manager/decisions", to: "ai_manager#decisions", as: :ai_manager_decisions
    get "ai_manager/planner", to: "ai_manager#planner", as: :ai_manager_planner
    get "ai_manager/patterns", to: "ai_manager#patterns", as: :ai_manager_patterns
    get "ai_manager/performance", to: "ai_manager#performance", as: :ai_manager_performance
    get "ai_manager/show_mission", to: "ai_manager#show_mission", as: :ai_manager_show_mission
    post "ai_manager/advance_phase/:mission_id", to: "ai_manager#advance_phase", as: :ai_manager_advance_phase
    post "ai_manager/reset_mission/:mission_id", to: "ai_manager#reset_mission", as: :ai_manager_reset_mission

    # Fixture-backed AI Manager task workbench (independent of world JSON loading).
    get "ai_manager/workbench", to: "ai_manager_workbench#index", as: :ai_manager_workbench
    get "ai_manager/workbench/tasks/:id", to: "ai_manager_workbench#show", as: :ai_manager_workbench_task
    get "ai_manager/workbench/tasks/:id/plan", to: "ai_manager_workbench#plan", as: :ai_manager_workbench_plan
    get "ai_manager/workbench/tasks/:id/execution", to: "ai_manager_workbench#execution", as: :ai_manager_workbench_execution
    post "ai_manager/workbench/tasks/:id/review", to: "ai_manager_workbench#review", as: :ai_manager_workbench_review
  end
end
