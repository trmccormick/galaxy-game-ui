class PlayerController < ApplicationController
  # Player-facing views (no admin access required)
  layout :get_layout

  def planetary
    @planet_name = "Earth"
  end

  private

  def get_layout
    # Use dashboard layout for player views (has sidebar nav)
    "dashboard"
  end
end
