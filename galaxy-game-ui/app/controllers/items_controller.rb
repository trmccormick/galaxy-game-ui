class ItemsController < ApplicationController
  skip_before_action :require_authentication

  def index
    @items = MockDataHelper.items(limit: 50)
    
    # Filter by material type
    if params[:type].present?
      @items = @items.select { |i| i[:material_type] == params[:type] }
    end
    
    # Search
    if params[:search].present?
      @items = @items.select { |i| 
        i[:name].downcase.include?(params[:search].downcase)
      }
    end
    
    # Sort
    sort = params[:sort] || "name"
    @items = @items.sort_by { |i| i[sort.to_sym] }
  rescue => e
    Rails.logger.error "ItemsController#index error: #{e.message}"
    @items = []
  end

  def show
    @item = MockDataHelper.item_by_name(params[:name])
    
    return redirect_to items_path, alert: "Item not found" if @item.nil?
    
    # Find blueprints using this item
    @blueprints_using_item = find_blueprints_using_item(@item[:name])
  rescue => e
    Rails.logger.error "ItemsController#show error: #{e.message}"
    redirect_to items_path, alert: "Error loading item"
  end

  private

  def find_blueprints_using_item(item_name)
    MockDataHelper.blueprints.select { |b|
      b[:materials].any? { |m| m[:item_name] == item_name }
    }
  rescue => e
    Rails.logger.error "Error finding blueprints: #{e.message}"
    []
  end
end
