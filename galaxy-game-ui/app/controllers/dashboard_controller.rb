class DashboardController < ApplicationController
  layout "dashboard"

  def index
    # Mock data for UI prototype — demonstration purposes only, not live backend integration
    @account = {
      email: Current.user&.email_address || 'player@galaxy.game',
      role: Current.user&.role || 'player',
      member_since: '2026-08-15',
      settlements_count: 8,
      systems_visited: 3,
      missions_completed: 12
    }

    @assets = [
      { name: 'GCC (Galactic Credits)', value: '47,250.00', type: 'currency' },
      { name: 'Iron Ore', value: '12,400 units', type: 'resource' },
      { name: 'Helium-3', value: '890 units', type: 'resource' },
      { name: 'Plasma Cells', value: '2,150 units', type: 'resource' }
    ]

    @settlements = [
      { name: 'New Alexandria', celestial_body: 'Earth', system: 'Sol System', population: 1247, status: 'active' },
      { name: 'Alpha Outpost', celestial_body: 'Proxima Centauri b', system: 'Alpha Centauri', population: 384, status: 'active' },
      { name: 'FR-48 Colony', celestial_body: 'FR-48b', system: 'FR-488530', population: 912, status: 'expanding' }
    ]

    @recent_activity = [
      { icon: '&#x1F680;', title: 'New colony established', desc: 'FR-488530 expansion approved', time: '2 hours ago', type: 'colony' },
      { icon: '&#x1F4B0;', title: 'Resource shipment completed', desc: 'Iron Ore delivered to Alpha Outpost', time: '6 hours ago', type: 'economy' },
      { icon: '&#x1F52C;', title: 'Research initiative started', desc: 'Atmospheric processing techniques', time: '1 day ago', type: 'research' }
    ]

    # Placeholder nav destinations (UI structure only)
    @nav_sections = {
      account: ['Overview'],
      galaxy: ['Galaxy Map', 'Star Systems', 'Settlements'],
      operations: ['Economy', 'Research', 'Missions']
    }
  end
end
