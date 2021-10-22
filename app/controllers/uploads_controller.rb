class UploadsController < ApplicationController
  before_action :set_organisation, only: [:new]

  def new
    authorize @organisation, :list_applicants?
    @configuration = @organisation.configuration
  end

  private

  def set_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
