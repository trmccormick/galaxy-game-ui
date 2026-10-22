class WormholesController < ApplicationController
  skip_before_action :require_authentication

  def index
    @wormhole_network = MockDataHelper.wormhole_network_post_snap
    @em_status = MockDataHelper.em_status
    @current_location = session[:current_system_id] || "SOL"
    @systems = @wormhole_network[:systems]
    @wormholes = @wormhole_network[:wormholes]
    @post_snap_context = @wormhole_network[:post_snap_status]
    
    # Admin only
    @is_admin = session[:admin] || false
    @hammer_protocol = @is_admin ? MockDataHelper.hammer_protocol_status : nil
  end

  def pathfind
    source = params[:source] || "SOL"
    destination = params[:destination]
    
    return render json: { error: "Destination required" }, status: 400 if destination.blank?
    
    network = MockDataHelper.wormhole_network_post_snap
    
    # Simple pathfinding (direct or via Sol)
    @path = find_route(source, destination, network[:systems])
    @route_wormholes = build_route_details(@path, network[:wormholes])
    
    if @path.empty? || @route_wormholes.empty?
      render json: { error: "No route found" }, status: 404
    else
      render json: { 
        path: @path, 
        wormholes: @route_wormholes,
        route_mass_limit: @route_wormholes.map { |w| w[:mass_limit] }.min.round(2)
      }
    end
  end

  def traverse
    destination = params[:destination]
    
    return render json: { error: "Destination required" }, status: 400 if destination.blank?
    
    network = MockDataHelper.wormhole_network_post_snap
    
    # Find wormhole for this route
    wh = network[:wormholes].find do |w| 
      (w[:system_a] == session[:current_system_id] && w[:system_b] == destination) ||
      (w[:system_a] == destination && w[:system_b] == session[:current_system_id])
    end
    
    if wh.nil?
      return render json: { error: "Wormhole not found" }, status: 404
    end
    
    # Check snap risk level for confirmation
    if wh[:snap_risk_level] == "danger" || wh[:snap_risk_level] == "caution"
      return render json: { 
        warning: "Wormhole at #{wh[:snap_risk_level].upcase} stability! Proceed with caution.",
        snap_risk: true,
        requires_confirmation: true
      }, status: 200
    end
    
    # Update session
    session[:current_system_id] = destination
    
    render json: { success: true, new_location: destination }
  rescue => e
    render json: { error: "Traversal failed: #{e.message}" }, status: 500
  end

  def trigger_snap
    unless session[:admin]
      return redirect_to root_path, alert: "Admin access required"
    end
    
    wormhole_id = params[:wormhole_id]
    
    if wormhole_id.blank?
      return render json: { error: "Wormhole ID required" }, status: 400
    end
    
    network = MockDataHelper.wormhole_network_post_snap
    wh = network[:wormholes].find { |w| w[:id] == wormhole_id.to_i }
    
    unless wh && wh[:snap_eligible]
      return render json: { error: "Snap not eligible for this wormhole" }, status: 400
    end
    
    # Simulate snap event (mock)
    render json: {
      snap_triggered: true,
      wormhole_id: wormhole_id,
      new_exit_coordinates: wh[:snap_coordinates],
      orphaned_systems: ["AOL-732356"],  # Eden temporarily orphaned
      em_field_generated: wh[:snap_risk_level] == "safe" ? 0 : (rand(1500..4000))
    }
  rescue => e
    render json: { error: "Snap trigger failed: #{e.message}" }, status: 500
  end

  private

  def find_route(source, destination, systems)
    return [] if source == destination
    
    # Direct connection check
    direct_wh = @wormholes.find do |w| 
      (w[:system_a] == source && w[:system_b] == destination) ||
      (w[:system_a] == destination && w[:system_b] == source)
    end
    
    if direct_wh
      return [source, destination]
    end
    
    # Via Sol (hub) - only for non-SOL systems
    if source != "SOL" && destination != "SOL"
      via_sol = true
      
      # Check path from source to SOL
      unless @wormholes.any? { |w| 
        (w[:system_a] == source && w[:system_b] == "SOL") ||
        (w[:system_a] == "SOL" && w[:system_b] == source)
      }
        via_sol = false
      end
      
      # Check path from SOL to destination
      if via_sol
        unless @wormholes.any? { |w| 
          (w[:system_a] == "SOL" && w[:system_b] == destination) ||
          (w[:system_a] == destination && w[:system_b] == "SOL")
        }
          via_sol = false
        end
      end
      
      return [source, "SOL", destination] if via_sol
    end
    
    []
  end

  def build_route_details(path, wormholes)
    @wormholes.select do |wh|
      path.include?(wh[:system_a]) && path.include?(wh[:system_b])
    end
  end
end
