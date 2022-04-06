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
    @all_configurations = policy_scope(::Configuration) & @department.configurations
    set_current_configuration
  end

  def set_organisation_upload
    @organisation = Organisation.find(params[:organisation_id])
    authorize @organisation, :upload?
    @all_configurations = @organisation.configurations
    @department = @organisation.department
    set_current_configuration
  end

  def set_current_configuration
    @current_configuration = \
      if params[:configuration_id].present?
        @all_configurations.find(params[:configuration_id])
      elsif @all_configurations.length == 1
        @all_configurations.first
      end
    @context_name = @current_configuration&.context_name
  end
end
