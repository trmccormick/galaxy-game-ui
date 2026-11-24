Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  get "dashboard", to: "dashboard#index", as: :dashboard
  get "about", to: "landing#about"
  root "landing#index"

  # Player views
  get "player/planetary", to: "player#planetary", as: :player_planetary
  get "player/space", to: "player/space#show", as: :player_space
  get "player/fleet-manager", to: "player/space#show", as: :player_fleet_manager, defaults: { workspace: "fleet_manager" }
  get "player/missions", to: "player/missions#index", as: :player_missions
  get "player/missions/new", to: "player/missions#new", as: :new_player_mission
  get "player/missions/:id", to: "player/missions#show", as: :player_mission
  get "player/missions/:id/edit", to: "player/missions#edit", as: :edit_player_mission

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    get "celestial_bodies", to: "celestial_bodies#index", as: :celestial_bodies
    get "celestial_bodies/:id", to: "celestial_bodies#show", as: :celestial_body

    get "map_studio", to: "map_studio#index", as: :map_studio
    get "map_studio/generate", to: "map_studio#generate", as: :map_studio_generate
    get "map_studio/browse", to: "map_studio#browse", as: :map_studio_browse
    get "map_studio/analyze/:id", to: "map_studio#analyze", as: :map_studio_analyze
    get "map_studio/apply/:id", to: "map_studio#apply", as: :map_studio_apply
    post "map_studio/apply/:id/simulate", to: "map_studio#simulate_apply", as: :map_studio_simulate_apply

    get "ai_manager", to: "ai_manager#index", as: :ai_manager
    get "ai_manager/missions", to: "ai_manager#missions", as: :ai_manager_missions
    get "ai_manager/decisions", to: "ai_manager#decisions", as: :ai_manager_decisions
    get "ai_manager/planner", to: "ai_manager#planner", as: :ai_manager_planner
    get "ai_manager/patterns", to: "ai_manager#patterns", as: :ai_manager_patterns
    get "ai_manager/performance", to: "ai_manager#performance", as: :ai_manager_performance
    get "ai_manager/show_mission", to: "ai_manager#show_mission", as: :ai_manager_show_mission
    post "ai_manager/advance_phase/:mission_id", to: "ai_manager#advance_phase", as: :ai_manager_advance_phase
    post "ai_manager/reset_mission/:mission_id", to: "ai_manager#reset_mission", as: :ai_manager_reset_mission

    # Shared task and repeatable mission library (fixture-backed UI prototype).
    get "ai_manager/library/tasks", to: "ai_manager_library#tasks", as: :ai_manager_library_tasks
    get "ai_manager/library/tasks/:id", to: "ai_manager_library#task", as: :ai_manager_library_task
    get "ai_manager/library/tasks/:id/edit", to: "ai_manager_library#edit_task", as: :edit_ai_manager_library_task
    get "ai_manager/library/missions", to: "ai_manager_library#missions", as: :ai_manager_library_missions
    get "ai_manager/library/missions/:id", to: "ai_manager_library#mission", as: :ai_manager_library_mission

    # Session-backed mission profile builder prototype.
    get "ai_manager/profiles/new", to: "ai_manager_profiles#new", as: :ai_manager_new_profile
    post "ai_manager/profiles", to: "ai_manager_profiles#create", as: :ai_manager_profiles
    get "ai_manager/profiles/:id", to: "ai_manager_profiles#show", as: :ai_manager_profile

    # Fixture-backed AI Manager task workbench (independent of world JSON loading).
    get "ai_manager/workbench", to: "ai_manager_workbench#index", as: :ai_manager_workbench
    get "ai_manager/workbench/tasks/:id", to: "ai_manager_workbench#show", as: :ai_manager_workbench_task
    get "ai_manager/workbench/tasks/:id/plan", to: "ai_manager_workbench#plan", as: :ai_manager_workbench_plan
    get "ai_manager/workbench/tasks/:id/execution", to: "ai_manager_workbench#execution", as: :ai_manager_workbench_execution
    post "ai_manager/workbench/tasks/:id/review", to: "ai_manager_workbench#review", as: :ai_manager_workbench_review
  end
end
