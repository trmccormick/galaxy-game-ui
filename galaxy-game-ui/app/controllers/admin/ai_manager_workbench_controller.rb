class Admin::AiManagerWorkbenchController < Admin::BaseController
  layout "dashboard"

  # The workbench consumes the same replaceable mock API as the overview.
  # Fixture data is temporary and does not control the live simulation.
  def index
    @systems = api.systems
    @selected_system = api.resolve_system(params[:system])
    @all_tasks = api.tasks(system_id: @selected_system)

    @filters = {
      status: params[:status].presence,
      category: params[:category].presence,
      query: params[:q].to_s.strip
    }
    @tasks = @all_tasks
    @tasks = @tasks.select { |task| task[:status] == @filters[:status] } if @filters[:status]
    @tasks = @tasks.select { |task| task[:category] == @filters[:category] } if @filters[:category]
    if @filters[:query].present?
      needle = @filters[:query].downcase
      @tasks = @tasks.select do |task|
        [task[:id], task[:title], task[:target], task[:origin], task[:source]].compact.any? { |value| value.downcase.include?(needle) }
      end
    end

    @status_options = api.status_options
    @status_labels = @status_options.index_with { |value| api.status_label(value) }
    @category_options = @all_tasks.map { |task| task[:category] }.uniq.sort
    @counts = api.overview(system_id: @selected_system)[:counts]
  end

  def show
    @task = find_task
    @system = api.system(@task[:system_id])
    @plan = api.plan(@task)
  end

  def plan
    @task = find_task
    @plan = api.plan(@task)
  end

  def execution
    @task = find_task
    @execution = api.execution(@task)
  end

  def review
    @task = find_task
    outcome = params[:outcome].to_s
    unless %w[approve reject defer].include?(outcome)
      return redirect_to admin_ai_manager_workbench_plan_path(@task[:id]), alert: "Choose a valid review action."
    end

    redirect_to admin_ai_manager_workbench_task_path(@task[:id]),
      notice: "#{outcome.humanize} recorded for this prototype session only; no game state was changed."
  end

  private

  def api
    @api ||= MockAiManagerApi.new
  end

  def find_task
    api.task(params[:id]) || raise(ActiveRecord::RecordNotFound)
  end
end
