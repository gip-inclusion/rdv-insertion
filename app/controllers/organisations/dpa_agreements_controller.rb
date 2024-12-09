module Organisations
  class DpaAgreementsController < ApplicationController
    before_action :set_organisation

    def create
      if params[:dpa_accepted]
        DpaAgreement.create(organisation: @organisation, agent: current_agent)
      else
        flash[:alert] = "Vous devez accepter le DPA pour continuer"
        redirect_to root_path
      end
    end

    private

    def set_organisation
      @organisation = current_organisation
      authorize @organisation, :configure?
    end
  end
end
