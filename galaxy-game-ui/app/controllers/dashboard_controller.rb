class DashboardController < ApplicationController
  skip_before_action :require_authentication

  def index
    @system_status = MockDataHelper.system_status
    @player_inventory = MockDataHelper.bay_inventory
    @player_units = MockDataHelper.active_units
    @market_panel = MockDataHelper.market_quick_panel
  end
end
