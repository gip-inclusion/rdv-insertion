module Organisations
  class DpaAgreementsController < ApplicationController
    before_action :set_organisation, :ensure_dpa_accepted

    def create
      dpa_agreement = DpaAgreement.new(agent: current_agent, organisation: @organisation)
      if dpa_agreement.save
        head :no_content
      else
        turbo_stream_display_custom_error_modal(
          title: "L'acceptation n'a pas fonctionné",
          description: "Veuillez contacter le support si le problème persiste.",
          errors: dpa_agreement.errors
        )
      end
    end

    private

    def ensure_dpa_accepted
      return if params[:dpa_accepted] == "1"

      turbo_stream_display_error_modal(["Vous devez accepter le DPA pour pouvoir continuer"])
    end

    def set_organisation
      @organisation = current_organisation
      authorize @organisation, :can_accept_dpa?
    end
  end
end
