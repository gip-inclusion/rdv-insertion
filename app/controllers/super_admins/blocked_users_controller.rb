class SuperAdmins::BlockedUsersController < SuperAdmins::ApplicationController
  before_action :set_starts_at, :set_ends_at, :set_blocked_users_grouped_by_day, :force_full_page_reload,
                only: :index

  private

  def set_starts_at
    @starts_at = params[:starts_at] || 1.year.ago
  end

  def set_ends_at
    @ends_at = params[:ends_at] || Time.zone.now
  end

  def set_blocked_users_grouped_by_day
    @blocked_users_grouped_by_day = BlockedUser.grouped_by_day(@starts_at, @ends_at)
  end
end
