module SuperAdmins
  class AgentsController < SuperAdmins::ApplicationController
    before_action :store_super_admin_id, :set_new_agent, only: [:sign_in_as]

    def sign_in_as
      # only super admins can impersonate agents ; this is ensured in the parent controller
      switch_accounts
      redirect_to root_url
    end

    private

    def store_super_admin_id
      @super_admin_id = current_agent.id
    end

    def set_new_agent
      @new_agent = Agent.find(params[:id])
    end

    def default_sorting_attribute
      :email
    end
  end
end
