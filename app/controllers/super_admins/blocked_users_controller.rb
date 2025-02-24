class SuperAdmins::BlockedUsersController < SuperAdmins::ApplicationController
  before_action :set_starts_at, :set_ends_at, :set_blocked_users_grouped_by_month

  private

  def set_starts_at
    @starts_at = params[:starts_at] || 1.year.ago
  end

  def set_ends_at
    @ends_at = params[:ends_at] || Time.zone.now
  end

  def set_blocked_users_grouped_by_month
    @blocked_users_grouped_by_month = BlockedUser.grouped_by_month(@starts_at, @ends_at)
  end
end
