class FileConfigurationsController < ApplicationController
  before_action :set_file_configuration, only: [:show]

  def show; end

  private

  def set_file_configuration
    @file_configuration = FileConfiguration.find(params[:id])
  end
end
