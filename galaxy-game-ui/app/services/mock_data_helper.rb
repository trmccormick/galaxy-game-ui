module MockDataHelper
  # Returns mock system status for dashboard
  def self.system_status
    {
      system_name: "Luna Settlement Alpha",
      player_gcc: 15_000_000,
      player_name: "Commander Nova",
      location: "Bay 4, Dock Station A",
      timestamp: "2026-10-20 17:30 UTC"
    }
  end

  # Returns mock character and settlement data
  def self.character_at_settlement(settlement_id = :antollare)
    {
      character_name: "Commander Nova",
      settlement: "ANTOLLARE III",
      isk_balance: 15_000_000,
      location: "Bay 4, Dock Station A"
    }
  end

  # Returns mock research queue
  def self.research_queue
    [
      { blueprint: "Structural I-Beams", progress: 65, eta: "2h 15m", level: 2 },
      { blueprint: "Refined Copper Sheets", progress: 40, eta: "5h 30m", level: 3 }
    ]
  end

  # Returns mock local facilities
  def self.local_facilities
    [
      { name: "Factory Unit Alpha", specializes_in: "Structural Components", status: "Manufacturing", utilization: 85 },
      { name: "Refinery Module Beta", specializes_in: "Ores & Metals", status: "Idle", utilization: 0 },
      { name: "Research Lab Gamma", specializes_in: "Blueprints", status: "Active", utilization: 100 }
    ]
  end

  # Returns mock local inventory
  def self.bay_inventory
    [
      { resource: "Water Ice", quantity: 850, max_qty: 1000, unit: "kg" },
      { resource: "Oxygen (O2)", quantity: 620, max_qty: 800, unit: "kg" },
      { resource: "Deuterium", quantity: 340, max_qty: 500, unit: "kg" },
      { resource: "Regolith", quantity: 4500, max_qty: 5000, unit: "kg" }
    ]
  end

  # Returns mock player inventory alias
  def self.player_inventory
    bay_inventory
  end

  # Returns mock manufacturing queue
  def self.manufacturing_queue
    [
      { job: "Structural I-Beams x500", facility: "Factory Unit Alpha", progress: 72, eta: "1h 45m", status: "In Progress" },
      { job: "Refined Copper x200", facility: "Factory Unit Alpha", progress: 0, eta: "3h 20m", status: "Queued" }
    ]
  end

  # Returns mock player ships/units
  def self.player_ships
    [
      { name: "Heavy Transport Tug Alpha", type: "Transport", status: "Docked", location: "Luna Settlement Alpha" },
      { name: "Logistics Hauler Beta", type: "Light Transport", status: "Docked", location: "Luna Settlement Alpha" },
      { name: "Scout Vessel Gamma", type: "Scout", status: "In Transit", destination: "Luna Station Prime", eta: "4h 20m" }
    ]
  end

  # Returns mock active units (alias for player ships)
  def self.active_units
    player_ships
  end

  # Returns mock NPC buy orders
  def self.npc_buy_orders
    [
      { corporation: "LDC (Lunar Development Corp)", needs: "Water Ice", quantity: 500, price_per_unit: 1200, total: 600_000 },
      { corporation: "AstroLift Logistics", needs: "Oxygen (O2)", quantity: 300, price_per_unit: 850, total: 255_000 },
      { corporation: "MDC (Mars Development Corp)", needs: "Deuterium", quantity: 200, price_per_unit: 2100, total: 420_000 }
    ]
  end

  # Returns mock player missions (escalated buy orders)
  def self.active_missions
    [
      { mission: "Secure Ice Delivery", offer: "LDC", reward: 150_000, deadline: "6 hours", status: "Available" },
      { mission: "Emergency Isotope Supply", offer: "AstroLift", reward: 85_000, deadline: "2 hours", status: "In Progress" }
    ]
  end

  # Returns mock wormhole network
  def self.wormhole_network
    [
      { system: "Luna Settlement Alpha", type: "Natural", stability: "95%", decay_timer: "22 hours", em_potential: "High" },
      { system: "Mars Cycler Station", type: "Artificial", stability: "100%", decay_timer: "N/A", em_potential: "Medium" },
      { system: "Luna Station Prime", type: "Artificial", stability: "100%", decay_timer: "N/A", em_potential: "None" }
    ]
  end

  # Returns mock AstroLift transit routes
  def self.astrolift_routes
    [
      { route: "Luna Settlement Alpha → Mars Cycler Station → Luna Station Prime", hops: 2, time: "4.5h", price: 50_000, capacity: "5000 m³" },
      { route: "Luna Settlement Alpha → Luna Station Prime (direct)", hops: 1, time: "2h", price: 85_000, capacity: "3000 m³" }
    ]
  end

  # Returns mock transit routes (alias)
  def self.transit_routes
    astrolift_routes
  end

  # Returns mock NPC corporations
  def self.npc_corporations
    [
      { name: "AstroLift", status: "Operating", current_activity: "Scheduling cycler departures", inventory_value: 2_500_000 },
      { name: "LDC", status: "Operating", current_activity: "Importing water ice from polar mines", inventory_value: 1_800_000 },
      { name: "MDC", status: "Operating", current_activity: "Harvesting regolith and metals", inventory_value: 3_200_000 }
    ]
  end

  # Returns mock AI Manager status for admin panel
  def self.ai_manager_status
    {
      directives: [
        { directive: "Expansion to Alpha Centauri", status: "Active", progress: "67%" },
        { directive: "Market Stabilization", status: "Active", progress: "42%" }
      ],
      priorities: { harvester: 60, market_import: 30, expansion: 10 },
      next_tick: "2026-10-20 18:00 UTC"
    }
  end

  # Returns mock Digital Twin scenarios
  def self.digital_twin_scenarios
    [
      { name: "Scenario A: 60% Harvester Focus", status: "Simulated", outcome: "Higher production, lower NPC fulfillment", time_to_stable: "12 days" },
      { name: "Scenario B: Balanced AI", status: "Simulated", outcome: "Mixed results, economy stable", time_to_stable: "8 days" }
    ]
  end

  # Returns mock buy order status for admin
  def self.buy_order_status
    [
      { item: "Water Ice", quantity: 500, npc_offering: "LDC", status: "Unfulfilled", escalation_eta: "2h" },
      { item: "Oxygen (O2)", quantity: 300, npc_offering: "AstroLift", status: "Mission Posted", reward: 85_000 },
      { item: "Deuterium", quantity: 200, npc_offering: "MDC", status: "AI Fulfilling (Harvester)", eta: "3h" }
    ]
  end

  # Returns mock economic indices for admin panel
  def self.economic_indices
    {
      pve_index: 4.2,
      energy_trade_index: 0.8,
      eap_index: 102500,
      em_trade_value: "High",
      updated_at: "2026-10-20 17:00 UTC"
    }
  end

  # Returns mock sim engine events for admin panel
  def self.sim_engine_events
    [
      { timestamp: "17:05", event: "AI Directive Update", detail: "Harvester priority changed from 45% to 60%" },
      { timestamp: "16:30", event: "Wormhole Decay Alert", detail: "Enedore JUMP gateway approaching threshold" },
      { timestamp: "15:45", event: "Market Stabilization", detail: "LDC buy orders matched to NPC supply" }
    ]
  end

  # Returns mock market quick panel data for dashboard
  def self.market_quick_panel
    npc_buy_orders + active_missions.map { |m| { corporation: m[:offer], needs: m[:mission], quantity: m[:reward], price_per_unit: nil, total: m[:reward] } }
  end
end
