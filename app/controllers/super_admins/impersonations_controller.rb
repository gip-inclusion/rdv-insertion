module SuperAdmins
  class ImpersonationsController < SuperAdmins::ApplicationController
    include SuperAdmins::Impersonate

    before_action :set_agent_to_impersonate, only: [:create]
    skip_before_action :authenticate_super_admin!, only: [:destroy]

    def create
      # only super admins can impersonate agents ; this is ensured in the parent controller
      impersonate_agent
      redirect_to root_path
    end

    def destroy
      unimpersonate_agent
      flash[:alert] = "Vous avez bien été reconnecté.e à votre compte"
      redirect_to params[:redirect_url] || root_path
    end

    private

    def set_agent_to_impersonate
      @agent_to_impersonate = Agent.find(params[:agent_id])
    end
  end
end
