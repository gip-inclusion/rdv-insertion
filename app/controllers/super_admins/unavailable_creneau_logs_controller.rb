module SuperAdmins
  class UnavailableCreneauLogsController < SuperAdmins::ApplicationController
    before_action :set_unavailable_creneau_logs_for_index, only: :index
    before_action :set_unavailable_creneau_logs_for_show, only: :show

    def scoped_resource
      super.order(created_at: :desc)
    end

    private

    def set_unavailable_creneau_logs_for_index
      @unavailable_creneau_logs = UnavailableCreneauLog.all
    end

    def set_unavailable_creneau_logs_for_show
      @unavailable_creneau_logs = UnavailableCreneauLog.where(organisation: requested_resource.organisation)
    end
  end
end
