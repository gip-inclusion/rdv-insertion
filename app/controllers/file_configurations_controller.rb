class FileConfigurationsController < ApplicationController
  before_action :set_organisation, :set_file_configuration, only: [:show]

  def show; end

  private

  def set_file_configuration
    @file_configuration = FileConfiguration.find(params[:id])
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    authorize @organisation, policy_class: OrganisationConfigurationPolicy
  end
end
