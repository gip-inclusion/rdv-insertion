# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module SuperAdmins
  class ApplicationController < Administrate::ApplicationController
    include AuthenticatedControllerConcern
    include SuperAdmins::Impersonate
    include SuperAdmins::RedirectAndRenderConcern
    # Needed to generate ActiveStorage urls locally, it sets the host and protocol
    include ActiveStorage::SetCurrent unless Rails.env.production?

    before_action :authenticate_super_admin!

    def authenticate_super_admin!
      return if current_agent.super_admin?

      if agent_impersonated?
        unimpersonate_agent
        return
      end

      redirect_to root_path, alert: "Vous n'avez pas accès à cette page"
    end
  end
end
