# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module SuperAdmins
  class ApplicationController < Administrate::ApplicationController
    include AuthenticatedControllerConcern
    include SuperAdmins::RedirectAndRenderConcern
    include SuperAdmins::PaperTrailConcern
    # Needed to generate ActiveStorage urls locally, it sets the host and protocol
    include ActiveStorage::SetCurrent unless Rails.env.production?

    before_action :authenticate_super_admin!

    private

    def authenticate_super_admin!
      if current_agent.super_admin?
        authenticate_super_admin_with_token!
      else
        redirect_to root_path, alert: "Vous n'avez pas accès à cette page"
      end
    end

    def authenticate_super_admin_with_token!
      return if current_agent.super_admin_token_verified_and_valid?

      current_agent.generate_and_send_super_admin_authentication_request!
      redirect_to new_super_admin_authentication_request_verification_path
    end

    def force_full_page_reload
      @force_full_page_reload = true
    end
  end
end
