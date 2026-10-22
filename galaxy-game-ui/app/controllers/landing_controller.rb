class LandingController < ApplicationController
  skip_before_action :require_authentication

  def index
    @systems = MockDataHelper.wormhole_network_post_snap[:systems]
    @wormholes = MockDataHelper.wormhole_network_post_snap[:wormholes]
    @post_snap_status = MockDataHelper.post_snap_status
    @em_status = MockDataHelper.em_status
    @current_system_id = session[:current_system_id] || "SOL"
    @hammer_protocol = session[:admin] ? MockDataHelper.hammer_protocol_status : nil
  end

  def enter_game
    if params[:system].present?
      session[:current_system_id] = params[:system]
    else
      session[:current_system_id] = "SOL"
    end
    redirect_to dashboard_path
  end

  private

  def system_stability_class(system)
    return "stable" if system[:id] == "SOL" || system[:id] == "EDEN"
    
    index = MockDataHelper.wormholes.find { |w| w[:system_b] == system[:name] }&.dig(:stability_index) || 0
    
    if index >= 0.8
      "stable"
    elsif index >= 0.5
      "unstable"
    else
      "critical"
    end
  end
end
