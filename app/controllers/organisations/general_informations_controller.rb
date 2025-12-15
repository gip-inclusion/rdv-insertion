module Organisations
  class GeneralInformationsController < ApplicationController
    PERMITTED_PARAMS = [
      :name, :phone_number, :email, :slug, :rdv_solidarites_organisation_id,
      :department_id, :safir_code, :logo, :remove_logo
    ].freeze

    before_action :set_organisation

    def show; end

    def edit; end

    def update
      @organisation.assign_attributes(organisation_params)
      if update_organisation.success?
        redirect_to organisation_general_information_path(@organisation)
      else
        turbo_stream_replace_error_list_with(update_organisation.errors)
      end
    end

    private

    def organisation_params
      params.expect(organisation: PERMITTED_PARAMS)
    end

    def set_organisation
      @organisation = policy_scope(Organisation).find(params[:organisation_id])
      authorize @organisation
      @department = @organisation.department
    end

    def update_organisation
      @update_organisation ||= Organisations::Update.call(organisation: @organisation)
    end
  end
end

