module Website
  class StaticPagesController < BaseController
    skip_before_action :authenticate_agent!

    include CguHelper

    def welcome
      flash[:error] = "Echec de la connexion" if request.env["omniauth.error"]

      redirect_to(authenticated_root_path) if current_agent
    end

    def legal_notice; end

    def cgu
      @version = params[:version] || most_recent_cgu_version

      raise ActionController::RoutingError, "Not Found" unless cgu_version_exists?(@version)
    end

    def privacy_policy; end

    def accessibility; end
  end
end
