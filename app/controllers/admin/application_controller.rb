# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include AuthenticatedControllerConcern
    include Admin::RedirectAndRenderConcern
    before_action :authenticate_super_admin!

    def authenticate_super_admin!
      return if current_agent.super_admin?

      redirect_to root_path, alert: "Vous n'avez pas accès à cette page"
    end
  end
end
