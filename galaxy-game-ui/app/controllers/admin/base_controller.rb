class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    return render_403 unless Current.user&.role_admin?
  end

  def render_403
    redirect_to dashboard_path, alert: "Access denied. Administrator privileges required."
  end
end
