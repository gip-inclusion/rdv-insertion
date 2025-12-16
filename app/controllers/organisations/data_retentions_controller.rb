module Organisations
  class DataRetentionsController < ApplicationController
    before_action :set_organisation

    def show; end

    def edit; end

    def update
      @organisation.assign_attributes(data_retention_params)
      if @organisation.save
        redirect_to organisation_data_retention_path(@organisation)
      else
        turbo_stream_replace_error_list_with(@organisation.errors.full_messages)
      end
    end

    private

    def set_organisation
      @organisation = Organisation.find(params[:organisation_id])
      authorize @organisation, :configure?
    end

    def data_retention_params
      params.expect(organisation: [:data_retention_duration_in_months])
    end
  end
end
