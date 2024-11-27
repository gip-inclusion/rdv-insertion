module SuperAdmins
  class UnavailableCreneauLogsController < SuperAdmins::ApplicationController
    def scoped_resource
      super.order(created_at: :desc)
    end
  end
end
