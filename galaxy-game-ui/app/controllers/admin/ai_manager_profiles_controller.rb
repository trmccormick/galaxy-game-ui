class Admin::AiManagerProfilesController < Admin::BaseController
  layout "dashboard"

  # Prototype mission profiles are instantiated from reusable library
  # templates. Drafts live in the Rails session only; they do not persist to
  # the game database or dispatch assets.
  def new
    @templates = mission_templates
    @template = @templates.find { |item| item[:id] == params[:template_id] } ||
      @templates.find { |item| item[:id] == "luna-precursor" } || @templates.first
    @available_assets = [
      "AI Manager — select at execution time",
      "Luna Base Alpha operations group",
      "Luna cargo / construction units",
      "Venus atmospheric harvester",
      "Unassigned"
    ]
  end

  def create
    attributes = params.require(:mission_profile).permit(
      :name, :objective, :target_body, :template_id,
      task_names: [], assignments: {}
    )
    template = mission_templates.find { |item| item[:id] == attributes[:template_id] }
    raise ActiveRecord::RecordNotFound unless template

    selected_names = Array(attributes[:task_names])
    tasks = template[:tasks].each_with_index.filter_map do |task, index|
      next unless selected_names.include?(task[:name])

      {
        "name" => task[:name],
        "role" => task[:role],
        "status" => task[:status],
        "assigned_asset" => attributes[:assignments][index.to_s].presence || "Unassigned"
      }
    end

    if tasks.empty?
      return redirect_to admin_ai_manager_new_profile_path(template_id: template[:id]),
        alert: "Select at least one task grouping for the mission profile."
    end

    profile = {
      "id" => "MP-#{SecureRandom.hex(3).upcase}",
      "name" => attributes[:name].presence || template[:name],
      "objective" => attributes[:objective].presence || template[:objective],
      "target_body" => attributes[:target_body].presence || template[:scope],
      "template_id" => template[:id],
      "template_name" => template[:name],
      "source_maturity" => template[:maturity],
      "tasks" => tasks,
      "created_at" => Time.current.iso8601,
      "prototype_only" => true
    }

    drafts = session[:ai_manager_profile_drafts] || {}
    drafts[profile["id"]] = profile
    session[:ai_manager_profile_drafts] = drafts

    redirect_to admin_ai_manager_profile_path(profile["id"]),
      notice: "Mission profile draft created in this browser session. No game state was changed."
  end

  def show
    drafts = session[:ai_manager_profile_drafts] || {}
    @profile = drafts[params[:id]]
    raise ActiveRecord::RecordNotFound unless @profile
  end

  private

  def mission_templates
    [
      {
        id: "luna-precursor",
        name: "Luna Precursor Mission Profile",
        objective: "Establish initial Luna infrastructure and prepare the settlement for follow-on operations.",
        scope: "Earth → Luna",
        maturity: "Experimental V2 profile example",
        tasks: [
          { name: "Precursor launch and arrival", role: "Initial deployment", status: "Profile phase example" },
          { name: "Landing pad and site infrastructure", role: "Site preparation", status: "Profile phase example" },
          { name: "Tank farm preparation", role: "Receiving infrastructure", status: "Profile phase example" },
          { name: "Venus harvester arrival", role: "Atmospheric supply", status: "References experimental V2 task" }
        ]
      },
      {
        id: "venus-atmospheric-harvest",
        name: "Venus Atmospheric Harvest Run",
        objective: "Maintain a repeatable supply of Venus-atmosphere cargo for Luna settlement processing.",
        scope: "Venus ↔ Luna",
        maturity: "Design example",
        tasks: [
          { name: "Prepare harvester and departure resources", role: "Dispatch readiness", status: "Illustrative task grouping" },
          { name: "Harvest current Venus atmospheric composition", role: "Atmospheric collection", status: "Illustrative task grouping" },
          { name: "Return to Luna with mixed cargo", role: "Transit and arrival", status: "Illustrative task grouping" },
          { name: "Offload into prepared receiving storage", role: "Arrival / offload", status: "Experimental V2 task example available" },
          { name: "Assess next run and repeat when conditions permit", role: "Turnaround", status: "AI Manager planning responsibility" }
        ]
      }
    ]
  end
end
