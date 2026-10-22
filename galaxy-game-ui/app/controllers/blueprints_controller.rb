class BlueprintsController < ApplicationController
  skip_before_action :require_authentication

  def index
    @blueprints = MockDataHelper.blueprints(limit: 20)
    
    # Apply filters
    @blueprints = @blueprints.select { |b| 
      b[:technology_level] == params[:tech_level] 
    } if params[:tech_level].present?
    
    # Apply search
    if params[:search].present?
      @blueprints = @blueprints.select { |b| 
        b[:name].downcase.include?(params[:search].downcase) 
      }
    end
    
    # Sort
    sort = params[:sort] || "name"
    @blueprints = @blueprints.sort_by { |b| b[sort.to_sym] }
  rescue => e
    Rails.logger.error "BlueprintsController#index error: #{e.message}"
    @blueprints = []
  end

  def show
    @blueprint = MockDataHelper.blueprint_by_name(params[:name])
    
    return redirect_to blueprints_path, alert: "Blueprint not found" if @blueprint.nil?
    
    # Calculate total cost (mock calculation)
    @blueprint[:total_cost] = @blueprint[:materials].sum { |m| m[:amount] * 10 }
  rescue => e
    Rails.logger.error "BlueprintsController#show error: #{e.message}"
    redirect_to blueprints_path, alert: "Error loading blueprint"
  end
end
