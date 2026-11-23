class Player::MissionsController < ApplicationController
  layout "dashboard"

  # Player-owned mission guidance fixtures. These screens do not edit shared
  # tasks or dispatch assets in the simulation.
  def index
    @missions = mission_fixtures
  end

  def show
    @mission = find_mission
  end

  def new
    @mission = blank_mission
    render :form
  end

  def edit
    @mission = find_mission
    render :form
  end

  private

  def find_mission
    mission_fixtures.find { |item| item[:id] == params[:id] } || raise(ActiveRecord::RecordNotFound)
  end

  def blank_mission
    {
      id: nil,
      name: "New player mission",
      objective: "",
      target: "",
      guidance: "",
      constraints: [],
      assets: [],
      status: "Draft"
    }
  end

  def mission_fixtures
    [
      {
        id: "luna-oxygen-supply",
        name: "Maintain Luna Oxygen Supply",
        objective: "Keep the settlement's oxygen reserve above its configured safety threshold.",
        target: "Luna Base",
        guidance: "Prioritize local production and storage recovery. Request imports when local capacity cannot meet the reserve target.",
        constraints: ["Preserve emergency reserve", "Avoid unnecessary Earth imports"],
        assets: ["Luna ISRU plant", "Oxygen storage train", "Luna cargo hauler"],
        status: "Active",
        updated: "Updated 2 days ago",
        manager_note: "Monitoring production rate and reserve trend; no new deployment requested."
      },
      {
        id: "venus-gas-supply",
        name: "Repeat Venus Gas Supply Runs",
        objective: "Build a dependable flow of mixed Venus atmospheric cargo to Luna for local processing.",
        target: "Venus ↔ Luna",
        guidance: "Use the Venus harvester when propellant, craft condition, launch opportunity, and receiving tank capacity permit. Preserve enough methane for the complete mission.",
        constraints: ["Do not launch without receiving storage", "Retain return propellant margin", "Ask before acquiring additional craft"],
        assets: ["Venus harvester skimmer", "Luna receiving tank farm"],
        status: "Draft",
        updated: "Created 1 week ago",
        manager_note: "Awaiting player approval of the first deployment plan."
      }
    ]
  end
end
