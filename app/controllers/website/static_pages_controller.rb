module Website
  class StaticPagesController < BaseController
    skip_before_action :authenticate_agent!

    def welcome
      flash[:error] = "Echec de la connexion" if request.env["omniauth.error"]

      redirect_to(organisations_path) if current_agent
    end

    def legal_notice; end

    def cgu; end

    def privacy_policy; end

    def accessibility; end
  end
end
