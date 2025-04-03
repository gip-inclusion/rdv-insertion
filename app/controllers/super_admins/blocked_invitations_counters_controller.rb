module SuperAdmins
  class BlockedInvitationsCountersController < SuperAdmins::ApplicationController
    before_action :set_starts_at, :set_ends_at, :set_blocked_invitations_counters_grouped_by_day,
                  :force_full_page_reload,
                  only: :index

    def scoped_resource
      super.order(created_at: :desc)
    end

    private

    def set_starts_at
      @starts_at = params[:starts_at] || 30.days.ago
    end

    def set_ends_at
      @ends_at = params[:ends_at] || Time.zone.now
    end

    def set_blocked_invitations_counters_grouped_by_day
      @blocked_invitations_counters_grouped_by_day = BlockedInvitationsCounter.all.grouped_by_day(
        @starts_at, @ends_at
      )
    end
  end
end
