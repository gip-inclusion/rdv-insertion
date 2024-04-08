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
    include SuperAdmins::SessionsConcern
    # Needed to generate ActiveStorage urls locally, it sets the host and protocol
    include ActiveStorage::SetCurrent unless Rails.env.production?

    before_action :authenticate_super_admin!

    def authenticate_super_admin!
      switch_back_to_super_admin_account if super_admin_acts_as_another_agent?

      return if current_agent.super_admin?

      redirect_to root_path, alert: "Vous n'avez pas accès à cette page"
    end

    private

    def switch_back_to_super_admin_account
      @super_admin_id = session[:rdv_solidarites_credentials]["super_admin_id"].to_i
      @new_agent = Agent.find(@super_admin_id)
      switch_accounts
      flash[:alert] = "#{@new_agent.first_name} #{@new_agent.last_name}, vous avez été reconnecté.e à votre compte" # rubocop:disable Rails/ActionControllerFlashBeforeRender
    end

    def super_admin_acts_as_another_agent?
      super_admin_credentials = session.dig(:rdv_solidarites_credentials, "super_admin_id")
      super_admin_credentials.present? && super_admin_credentials.to_i != current_agent.id
    end
  end
end
