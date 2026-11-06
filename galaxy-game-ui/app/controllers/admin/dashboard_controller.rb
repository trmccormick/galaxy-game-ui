class Admin::DashboardController < Admin::BaseController
  layout "dashboard"

  def index
    @account = {
      email: Current.user&.email_address || 'admin@galaxy.game',
      role: 'admin',
      member_since: '2026-08-15'
    }

    # Placeholder admin metrics — prototype only
    @user_count = 2
    @system_count = 3
    @pending_approvals = 0
    @active_settlements = 3
  end
end
