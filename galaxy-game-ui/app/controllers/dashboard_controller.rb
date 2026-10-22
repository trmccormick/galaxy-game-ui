class DashboardController < ApplicationController
  skip_before_action :require_authentication

  def index
    @system_status = MockDataHelper.system_status
    @player_name = @system_status[:player_name]
    @current_system = session[:current_system_id] || "SOL"
    @bay_items     = MockDataHelper.bay_inventory       # Panel 1: Bay Inventory
    @ships         = MockDataHelper.player_ships        # Panel 2: Fleet Status
    @orders        = MockDataHelper.npc_buy_orders       # Panel 5: Market/Orders (placeholder)
    @missions      = MockDataHelper.active_missions      # Panel 5: Missions (placeholder)
    @production_queue = MockDataHelper.manufacturing_queue # Panel 3: Production Queue
    
    # Wormhole quick view data for Panel 4
    @wormhole_data = MockDataHelper.wormhole_network_post_snap
    @available_wormholes = filter_wormholes_by_location(@current_system)
    
    # EM Economy status
    @em_status = MockDataHelper.em_status
    
    # System selector data
    @systems = MockDataHelper.wormhole_network_post_snap[:systems]
  end

  private

  def filter_wormholes_by_location(system_id)
    return [] if system_id.blank?
    
    @wormhole_data[:wormholes].select do |wh|
      wh[:system_a] == system_id || wh[:system_b] == system_id ||
      wh[:system_a_id] == system_id || wh[:system_b_id] == system_id
    end
  end
end
