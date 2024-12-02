module SuperAdmins
  class UnavailableCreneauLogsController < SuperAdmins::ApplicationController
    before_action :set_unavailable_creneau_logs, only: :index

    def scoped_resource
      super.order(created_at: :desc)
    end

    private

    def set_unavailable_creneau_logs
      @unavailable_creneau_logs = UnavailableCreneauLog.all
    end
  end
end
