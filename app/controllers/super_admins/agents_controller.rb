module SuperAdmins
  class AgentsController < SuperAdmins::ApplicationController
    private

    def default_sorting_attribute
      :email
    end
  end
end
