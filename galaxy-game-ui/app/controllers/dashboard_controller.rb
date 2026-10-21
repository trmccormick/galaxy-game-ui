class DashboardController < ApplicationController
  skip_before_action :require_authentication

  def index
    @system_status = MockDataHelper.system_status
    @bay_items     = MockDataHelper.bay_inventory       # was @player_inventory
    @ships         = MockDataHelper.player_ships        # for later tasks
    @orders        = MockDataHelper.npc_buy_orders       # for later tasks
    @missions      = MockDataHelper.active_missions      # for later tasks
    @market        = MockDataHelper.market_quick_panel   # existing but renamed
  end
end
