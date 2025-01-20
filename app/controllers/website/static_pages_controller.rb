module Website
  class StaticPagesController < BaseController
    skip_before_action :authenticate_agent!

    def welcome
      if request.env["omniauth.error"]
        flash[:error] = "Echec de la connexion"
      end

      redirect_to(organisations_path) if current_agent
    end

    def legal_notice; end

    def cgu; end

    def privacy_policy; end

    def accessibility; end
  end
end
