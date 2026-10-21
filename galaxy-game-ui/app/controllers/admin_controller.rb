class AdminController < ApplicationController
  def index
    @ai_manager = MockDataHelper.ai_manager_status
    @economic_indices = MockDataHelper.economic_indices
    @event_log = MockDataHelper.sim_engine_events
  end
end
