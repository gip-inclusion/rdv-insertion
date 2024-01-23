class UploadsController < ApplicationController
  before_action :set_all_configurations, for: [:category_selection]

  before_action :set_organisation, :set_department, :check_if_category_is_selected, :set_all_configurations,
                :set_current_configuration, :set_motif_category_name, :set_file_configuration,
                for: [:new]

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
      policy_scope(::Configuration).joins(:organisation)
                                   .where(current_organisation_filter)
                                   .uniq(&:motif_category_id)

    @all_configurations =
      department_level? ? @all_configurations.sort_by(&:department_position) : @all_configurations.sort_by(&:position)
  end

  def set_current_configuration
    return if params[:configuration_id].blank?

    @current_configuration = policy_scope(::Configuration).preload(:file_configuration).find(params[:configuration_id])

    return if @current_configuration

    redirect_to(
      uploads_category_selection_structure_users_path,
      flash: { error: "La configuration sélectionnée n'est pas valide" }
    )
  end

  def set_motif_category_name
    @motif_category_name = @current_configuration&.motif_category_name
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

    redirect_to(uploads_category_selection_structure_users_path)
  end

  def category_selected?
    params[:configuration_id].present? || params[:category] == "none"
  end
end
