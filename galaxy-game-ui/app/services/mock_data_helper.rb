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

  # Returns mock wormhole network (original placeholder)
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

  # Returns mock AI Manager status for admin panel (original)
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

  # =====================================================
  # POST-SNAP ENHANCEMENTS (Task 1 addition)
  # All new methods below support Galaxy Game UI Post-Snap MVP
  # =====================================================

  # Returns Post-Snap wormhole network data structure
  def self.wormhole_network_post_snap
    {
      systems: SYSTEMS_DEFAULT.values,
      wormholes: WORMHOLES_WITH_NAMES,
      current_location: "SOL",
      current_timestamp: Time.now,
      post_snap_status: POST_SNAP_STATUS,
      ai_manager_status: AI_MANAGER
    }
  end

  # Post-Snap system definitions (constant)
  SYSTEMS = {
    SOL:   { id: "SOL", name: "Sol", system_mass: 500_000, stability_index_base: 0.95, galaxy: "Milky Way", known_data_level: "complete" },
    SYS_B: { id: "SYS_B", name: "GJ 1061", system_mass: 250_000, stability_index_base: 0.68, galaxy: "Milky Way", known_data_level: "partial" },
    EDEN:  { id: "EDEN", name: "Eden", identifier: "AOL-732356", system_mass: 300_000, stability_index_base: 0.95, galaxy: "Milky Way", known_data_level: "partial", post_snap: { was_orphaned: true, orphan_duration_hours: 18, reconnected_via: "artificial_wormhole_station", aws_location: "L3 Lagrange Point" } }
  }.freeze

  # Post-Snap wormhole definitions (constant)
  WORMHOLES = [
    { id: 1, name: "Sol-GJ 1061 Natural Link", system_a_id: "SOL", system_b_id: "SYS_B", system_a_mass: 500_000, system_b_mass: 250_000, natural: true, wormhole_type: "traversable", stability_index: 0.78, stability_decay_per_day: 0.02, em_potential: "high", em_reserves: 8_500, em_harvest_rate: 150, em_maintenance_cost: 250, system_mass: 500_000, em_surplus: 8_500, mass_limit: 37.05, cumulative_transit_mass_a_to_b: 250, cumulative_transit_mass_b_to_a: 180, snap_risk_level: "caution", recapture_satellites: 3, stabilizer_count: 0, counterbalance_quality: 0.0, one_way: false, traversed: false, snap_eligible: true, snap_coordinates: [78.3, 45.6, 12.1] },
    { id: 2, name: "Sol-Eden Artificial Link", system_a_id: "SOL", system_b_id: "EDEN", system_a_mass: 500_000, system_b_mass: 300_000, natural: false, wormhole_type: "traversable", stability_index: 0.95, em_potential: "none", em_reserves: 15_000, em_maintenance_cost: 400, em_harvest_rate: 0, mass_limit: 57.0, cumulative_transit_mass_a_to_b: 120, cumulative_transit_mass_b_to_a: 80, snap_risk_level: "safe", aws_operational: true, aws_location: "L3 Lagrange Point", recapture_satellites: 0, stabilizer_count: 2, counterbalance_quality: 0.95, one_way: false, traversed: true, snap_eligible: false }
  ].freeze

  # Helper constants derived from SYSTEMS and WORMHOLES
  SYSTEMS_DEFAULT = { "SOL" => SYSTEMS[:SOL], "SYS_B" => SYSTEMS[:SYS_B], "EDEN" => SYSTEMS[:EDEN] }.freeze
  WORMHOLES_WITH_NAMES = WORMHOLES.map { |w| w.merge(system_a: SYSTEMS_DEFAULT[w[:system_a_id]][:name], system_b: SYSTEMS_DEFAULT[w[:system_b_id]][:name]) }
  POST_SNAP_STATUS = { snap_event_date: "2026-10-01T14:32:00Z", original_system_b_coordinates: [45.2, 123.8, 67.4], eden_orphaned_duration_hours: 18, aws_reconstruction_date: "2026-10-02T09:15:00Z", ai_manager_status: "active" }.freeze
  AI_MANAGER = { snap_awareness: true, next_action: "rebuild Eden infrastructure" }

  # Returns system list (convenience accessor)
  def self.systems; SYSTEMS_DEFAULT.values; end
  def self.wormholes; WORMHOLES_WITH_NAMES; end
  def self.post_snap_status; POST_SNAP_STATUS; end

  # Returns global EM economy state
  def self.em_status
    { total_em_reserves: 23_500, daily_harvest_rate: 150, daily_consumption: 650, net_daily_flow: -500, days_until_critical: 47, recapture_satellites_active: 3, aws_efficiency: 0.95 }
  end

  # Returns snap mechanic state (admin-only in UI)
  def self.hammer_protocol_status
    { eligible_wormholes: ["sol-system-b-natural"], system_b_natural_wh: { current_mass_limit: 37, current_transit_mass: 12, snap_trigger_threshold: 35, snap_ready: false, projected_new_location: [78.3, 45.6, 12.1], orphan_risk_systems: ["eden"], estimated_em_field_value: 2_500 } }
  end

  # Returns blueprint catalog (limit defaults to 10)
  def self.blueprints(limit = 10)
    BLUEPRINTS.take(limit)
  end

  # Returns single blueprint by name
  def self.blueprint_by_name(name)
    BLUEPRINTS.find { |b| b[:name].downcase == name.downcase }
  end

  # Returns item catalog (limit defaults to 20, optional filter_by_type)
  def self.items(limit = 20, filter_by_type: nil)
    filtered = filter_by_type ? ITEMS.select { |i| i[:material_type] == filter_by_type } : ITEMS
    filtered.take(limit)
  end

  # Returns single item by name
  def self.item_by_name(name)
    ITEMS.find { |i| i[:name].downcase == name.downcase }
  end

  # Returns asset path mapping for crafts, logos, biomes
  def self.asset_map; ASSET_MAP; end

  # Returns list of missing assets (flagged for generation)
  def self.missing_assets; ASSET_MAP.select { |_, v| v.nil? }.map(&:first); end

  # Blueprint catalog data (constant)
  BLUEPRINTS = [
    { id: 1, name: "Basic Spaceship", description: "Construct a basic spaceship for interplanetary travel", materials: [{ item_name: "Steel Ingot", amount: 150 }, { item_name: "Aluminum Ingot", amount: 75 }, { item_name: "Copper Wire", amount: 50 }], research_level: 2, time_efficiency: 0.95, material_efficiency: 0.92, licensed_runs_remaining: 5, production_time_hours: 48, output_quantity: 1, technology_level: "basic" },
    { id: 2, name: "Advanced Transport", description: "High-capacity transport vessel for long-range missions", materials: [{ item_name: "Titanium Plate", amount: 200 }, { item_name: "Reactor Core", amount: 1 }, { item_name: "Plasma Conduit", amount: 40 }], research_level: 4, time_efficiency: 0.88, material_efficiency: 0.90, licensed_runs_remaining: 3, production_time_hours: 72, output_quantity: 1, technology_level: "advanced" },
    { id: 3, name: "Scout Probe", description: "Small reconnaissance probe for system exploration", materials: [{ item_name: "Silicon Chip", amount: 10 }, { item_name: "Micro Circuit", amount: 5 }, { item_name: "Photovoltaic Cell", amount: 20 }], research_level: 1, time_efficiency: 0.98, material_efficiency: 0.97, licensed_runs_remaining: nil, production_time_hours: 6, output_quantity: 3, technology_level: "basic" },
    { id: 4, name: "Heavy Harvester", description: "Industrial-grade resource extraction vehicle", materials: [{ item_name: "Steel Ingot", amount: 300 }, { item_name: "Hydraulic Piston", amount: 12 }, { item_name: "Fusion Cell", amount: 8 }], research_level: 3, time_efficiency: 0.90, material_efficiency: 0.85, licensed_runs_remaining: 10, production_time_hours: 96, output_quantity: 1, technology_level: "intermediate" },
    { id: 5, name: "Mining Drill", description: "Precision drill for asteroid mining operations", materials: [{ item_name: "Tungsten Carbide", amount: 100 }, { item_name: "Diamond Drill Bit", amount: 4 }, { item_name: "Hydraulic Fluid", amount: 200 }], research_level: 3, time_efficiency: 0.92, material_efficiency: 0.88, licensed_runs_remaining: 7, production_time_hours: 60, output_quantity: 1, technology_level: "intermediate" },
    { id: 6, name: "Defense Platform", description: "Orbital defense turret array for base protection", materials: [{ item_name: "Steel Ingot", amount: 500 }, { item_name: "Plasma Conduit", amount: 100 }, { item_name: "Reactor Core", amount: 2 }], research_level: 5, time_efficiency: 0.85, material_efficiency: 0.80, licensed_runs_remaining: 2, production_time_hours: 120, output_quantity: 1, technology_level: "advanced" },
    { id: 7, name: "Cargo Container", description: "Standard modular cargo container for bulk transport", materials: [{ item_name: "Aluminum Ingot", amount: 200 }, { item_name: "Welding Material", amount: 50 }, { item_name: "Sealant Compound", amount: 30 }], research_level: 1, time_efficiency: 0.96, material_efficiency: 0.94, licensed_runs_remaining: nil, production_time_hours: 8, output_quantity: 5, technology_level: "basic" },
    { id: 8, name: "Fuel Refinery", description: "Compact refinery for processing raw fuel from gas giants", materials: [{ item_name: "Steel Ingot", amount: 250 }, { item_name: "Catalyst Module", amount: 15 }, { item_name: "Pressure Vessel", amount: 8 }], research_level: 4, time_efficiency: 0.87, material_efficiency: 0.91, licensed_runs_remaining: 4, production_time_hours: 84, output_quantity: 1, technology_level: "advanced" },
    { id: 9, name: "Med Bay Module", description: "Medical bay module for long-range vessel support", materials: [{ item_name: "Medical Supply Kit", amount: 20 }, { item_name: "Stereo Microscope", amount: 2 }, { item_name: "Sterilization Unit", amount: 4 }], research_level: 3, time_efficiency: 0.93, material_efficiency: 0.95, licensed_runs_remaining: 6, production_time_hours: 36, output_quantity: 1, technology_level: "intermediate" },
    { id: 10, name: "Shield Generator", description: "Energy shield generator for vessel or station defense", materials: [{ item_name: "Crystal Matrix", amount: 50 }, { item_name: "Plasma Conduit", amount: 30 }, { item_name: "Reactor Core", amount: 1 }], research_level: 5, time_efficiency: 0.82, material_efficiency: 0.78, licensed_runs_remaining: 1, production_time_hours: 144, output_quantity: 1, technology_level: "advanced" }
  ].freeze

  # Item catalog data (constant) — 9 material types: manufactured_goods, metal, component, processed_material, gas, consumable, liquid, fuel, raw_material
  ITEMS = [
    { id: 1, name: "Steel Ingot", description: "Raw refined steel, suitable for construction and manufacturing", material_type: "processed_material", amount: 500, rarity: "common", source: "Refinery Module", is_container: false, durability: 100, unit_weight: 2.5, tags: ["metal", "construction", "refinable"], image_path: nil },
    { id: 2, name: "Aluminum Ingot", description: "Lightweight metal used in spacecraft hull construction", material_type: "processed_material", amount: 350, rarity: "common", source: "Smelter", is_container: false, durability: 95, unit_weight: 1.8, tags: ["metal", "construction", "lightweight"], image_path: nil },
    { id: 3, name: "Copper Wire", description: "High-conductivity wiring for electrical systems", material_type: "processed_material", amount: 200, rarity: "common", source: "Mining/Smelting", is_container: false, durability: 80, unit_weight: 0.5, tags: ["component", "electrical"], image_path: nil },
    { id: 4, name: "Titanium Plate", description: "Reinforced titanium alloy armor plating", material_type: "metal", amount: 150, rarity: "uncommon", source: "Deep Mine", is_container: false, durability: 120, unit_weight: 8.0, tags: ["metal", "armor", "advanced"], image_path: nil },
    { id: 5, name: "Reactor Core", description: "Compact fusion reactor core for power generation", material_type: "component", amount: 12, rarity: "rare", source: "Specialist Fabricator", is_container: false, durability: 200, unit_weight: 15.0, tags: ["component", "power", "high-tech"], image_path: nil },
    { id: 6, name: "Plasma Conduit", description: "High-temperature conduit for plasma energy transfer", material_type: "component", amount: 80, rarity: "uncommon", source: "Engineering Bay", is_container: false, durability: 90, unit_weight: 1.2, tags: ["component", "energy", "plasma"], image_path: nil },
    { id: 7, name: "Silicon Chip", description: "Standard processor chip for electronics", material_type: "component", amount: 500, rarity: "common", source: "Micro Fabrication", is_container: false, durability: 60, unit_weight: 0.01, tags: ["component", "electronics"], image_path: nil },
    { id: 8, name: "Hydraulic Fluid", description: "Pressurized fluid for hydraulic systems", material_type: "liquid", amount: 300, rarity: "common", source: "Chemical Plant", is_container: true, durability: 70, unit_weight: 1.5, tags: ["liquid", "industrial"], image_path: nil },
    { id: 9, name: "Hydrogen Fuel", description: "Compressed hydrogen for propulsion systems", material_type: "fuel", amount: 1000, rarity: "common", source: "Electrolysis Plant", is_container: true, durability: 50, unit_weight: 0.09, tags: ["fuel", "propulsion"], image_path: nil },
    { id: 10, name: "Helium-3 Gas", description: "Rare isotope for fusion reactor fuel", material_type: "gas", amount: 200, rarity: "rare", source: "Gas Giant Mining", is_container: true, durability: 40, unit_weight: 0.13, tags: ["gas", "fuel", "fusion"], image_path: nil },
    { id: 11, name: "Medical Supply Kit", description: "Emergency medical supplies for field use", material_type: "consumable", amount: 50, rarity: "common", source: "Pharma Lab", is_container: false, durability: 365, unit_weight: 2.0, tags: ["consumable", "medical"], image_path: nil },
    { id: 12, name: "Welding Material", description: "Industrial welding rods and flux compound", material_type: "processed_material", amount: 400, rarity: "common", source: "Manufacturing Plant", is_container: false, durability: 180, unit_weight: 0.8, tags: ["processed_material", "construction"], image_path: nil },
    { id: 13, name: "Catalyst Module", description: "Chemical catalyst for industrial refinement processes", material_type: "component", amount: 25, rarity: "uncommon", source: "Advanced Lab", is_container: false, durability: 90, unit_weight: 3.0, tags: ["component", "industrial", "chemistry"], image_path: nil },
    { id: 14, name: "Pressure Vessel", description: "Sealed chamber for high-pressure gas storage", material_type: "manufactured_goods", amount: 30, rarity: "uncommon", source: "Industrial Fabricator", is_container: true, durability: 150, unit_weight: 25.0, tags: ["manufactured_goods", "storage"], image_path: nil },
    { id: 15, name: "Stereo Microscope", description: "Precision optical instrument for material analysis", material_type: "component", amount: 5, rarity: "rare", source: "Optics Lab", is_container: false, durability: 300, unit_weight: 8.0, tags: ["component", "scientific"], image_path: nil },
    { id: 16, name: "Crystal Matrix", description: "Crystalline lattice structure for energy containment", material_type: "raw_material", amount: 40, rarity: "rare", source: "Geode Extraction", is_container: false, durability: 75, unit_weight: 4.0, tags: ["raw_material", "energy", "crystal"], image_path: nil },
    { id: 17, name: "Tungsten Carbide", description: "Ultra-hard alloy for drill bits and cutting tools", material_type: "metal", amount: 100, rarity: "uncommon", source: "Smelting Facility", is_container: false, durability: 180, unit_weight: 6.5, tags: ["metal", "industrial", "hardened"], image_path: nil },
    { id: 18, name: "Diamond Drill Bit", description: "Industrial-grade diamond-tipped drill for asteroid mining", material_type: "component", amount: 20, rarity: "uncommon", source: "Synthetic Diamond Lab", is_container: false, durability: 500, unit_weight: 0.5, tags: ["component", "mining", "precision"], image_path: nil },
    { id: 19, name: "Sealant Compound", description: "Vacuum-rated sealant for hull repairs and construction", material_type: "processed_material", amount: 100, rarity: "common", source: "Chemical Plant", is_container: true, durability: 730, unit_weight: 1.0, tags: ["processed_material", "maintenance"], image_path: nil },
    { id: 20, name: "Photovoltaic Cell", description: "Solar panel cell for power generation in low-light conditions", material_type: "manufactured_goods", amount: 60, rarity: "common", source: "Photonics Workshop", is_container: false, durability: 1825, unit_weight: 0.3, tags: ["manufactured_goods", "energy", "solar"], image_path: nil }
  ].freeze

  # Asset mapping (crafts, logos, biomes) — nil values indicate missing assets
  ASSET_MAP = {
    "Spaceship" => "/data/images/catalog/crafts/space/spacecraft/spaceship.png",
    "Lander"    => "/data/images/catalog/crafts/space/landers/lander.png",
    "Scout Probe" => nil,
    "Heavy Harvester" => nil,
    "Wormhole Transit Consortium" => "/data/images/logos/Wormhole Transit Consortium.png",
    "AstroLift" => "/data/images/logos/AstroLift.png",
    "LDC (Lunar Development Corp)" => nil,
    "MDC (Mars Development Corp)" => nil,
    "Forest" => "/data/images/biomes/forest.png",
    "Desert" => "/data/images/biomes/hot_desert.png",
    "Plains" => "/data/images/biomes/plains.png"
  }.freeze
end
