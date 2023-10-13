class UploadsController < ApplicationController
  before_action :set_organisation, :set_department, :check_if_category_is_selected,
                :set_all_configurations, :set_current_configuration, :set_file_configuration,
                for: [:new]
  before_action :set_organisation, :set_department, :set_all_configurations,
                for: [:category_selection]

  def new; end

  def category_selection; end

  private

  def set_organisation
    return if department_level?

    @organisation = Organisation.find(params[:organisation_id])
    authorize @organisation, :upload?
  end

  def set_department
    @department = department_level? ? Department.find(params[:department_id]) : @organisation.department
    authorize @department, :upload? if department_level?
  end

  def set_all_configurations
    @all_configurations =
      if department_level?
        (
          policy_scope(::Configuration).includes(:motif_category, :file_configuration) &
          @department.configurations
        ).uniq(&:motif_category_id)
      else
        @organisation.configurations.includes(:motif_category, :file_configuration)
      end

    @all_configurations = @all_configurations.sort_by(&:position)
  end

  def set_current_configuration
    return if params[:configuration_id].blank?

    @current_configuration = @all_configurations.find { |config| config.id == params[:configuration_id].to_i }

    if @current_configuration.nil?
      redirect_to(category_selection_path, flash: { error: "La configuration sélectionnée n'est pas valide" })
      return
    end

    @motif_category_name = @current_configuration.motif_category_name
  end

  def set_file_configuration
    @file_configuration =
      if @current_configuration.present?
        @current_configuration.file_configuration
      else
        # we take the most used config in this case
        @all_configurations.map(&:file_configuration).tally.max_by { |_file_config, count| count }.first
      end
  end

  def check_if_category_is_selected
    return if category_selected?

    redirect_to(category_selection_path)
  end

  def category_selection_path
    if department_level?
      uploads_category_selection_department_users_path(@department)
    else
      uploads_category_selection_organisation_users_path(@organisation)
    end
  end

  def category_selected?
    params[:configuration_id].present? || params[:category] == "none"
  end
end
