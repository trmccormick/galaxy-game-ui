class WormholesController < ApplicationController
  skip_before_action :require_authentication

  def index
    @wormhole_network = MockDataHelper.wormhole_network
    @transit_routes = MockDataHelper.transit_routes
  end
end
