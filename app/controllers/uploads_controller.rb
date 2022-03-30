class UploadsController < ApplicationController
  def new
    if params[:department_id].present?
      set_department_upload
    elsif params[:organisation_id].present?
      set_organisation_upload
    end
  end

  private

  def set_department_upload
    @department = Department.find(params[:department_id])
    authorize @department, :upload?
    @organisation = nil
    @configurations = @department.configurations
    set_configuration
  end

  def set_organisation_upload
    @organisation = Organisation.find(params[:organisation_id])
    authorize @organisation, :upload?
    @configurations = @organisation.configurations
    @department = @organisation.department
    set_configuration
  end

  def set_configuration
    @configuration = \
      if params[:configuration_id].present?
        @configurations.find(params[:configuration_id])
      elsif @configurations.length == 1
        @configurations.first
      end
  end
end
