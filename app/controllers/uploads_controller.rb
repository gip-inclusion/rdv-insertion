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
  end

  def set_organisation_upload
    @organisation = Organisation.find(params[:organisation_id])
    authorize @organisation, :upload?
    @configurations = @organisation.configurations
    @department = @organisation.department
  end
end
