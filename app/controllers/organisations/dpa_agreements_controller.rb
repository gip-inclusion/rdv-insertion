module Organisations
  class DpaAgreementsController < ApplicationController
    before_action :set_organisation

    def create
      if save_dpa_agreement.success?
        head :no_content
      else
        turbo_stream_display_custom_error_modal(
          title: "L'acceptation n'a pas fonctionné",
          description: "Veuillez contacter le support si le problème persiste.",
          errors: save_dpa_agreement.errors
        )
      end
    end

    private

    def save_dpa_agreement
      @save_dpa_agreement ||= DpaAgreements::Save.call(
        dpa_accepted: params[:dpa_accepted] == "1",
        agent: current_agent,
        organisation: @organisation
      )
    end

    def set_organisation
      @organisation = current_organisation
      authorize @organisation, :can_accept_dpa?
    end
  end
end
