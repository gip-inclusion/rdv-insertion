class CategoryConfigurationsController < ApplicationController # rubocop:disable Metrics/ClassLength
  PERMITTED_PARAMS = [
    { invitation_formats: [] }, :convene_user, :rdv_with_referents, :file_configuration_id,
    :invite_to_user_organisations_only, :number_of_days_before_invitations_expire, :motif_category_id,
    :phone_number, :email_to_notify_no_available_slots, :email_to_notify_rdv_changes
  ].freeze

  before_action :set_organisation
  before_action :set_category_configuration, only: [:destroy,
                                                    :edit_rdv_preferences, :update_rdv_preferences,
                                                    :edit_messages, :update_messages,
                                                    :edit_notifications, :update_notifications,
                                                    :edit_file_import, :update_file_import]
  before_action :set_department, :set_file_configurations, only: [:new, :new_select_file_import, :edit_file_import]
  before_action :set_available_motif_categories, only: [:new]

  def new
    @category_configuration = CategoryConfiguration.new(organisation: @organisation)
    render layout: "no_footer_white_bg"
  end

  def create
    @category_configuration = CategoryConfiguration.new(organisation: @organisation)
    @category_configuration.assign_attributes(**category_configuration_params.compact_blank)
    if create_configuration.success?
      flash[:success] = "La configuration a été créée avec succès"
      redirect_to organisation_configuration_categories_path(@organisation)
    else
      turbo_stream_replace_error_list_with(create_configuration.errors)
    end
  end

  def destroy
    @category_configuration.destroy!
    flash[:success] = "La configuration a été supprimée avec succès"
    redirect_to organisation_configuration_categories_path(@organisation)
  end

  def edit_rdv_preferences; end

  def update_rdv_preferences
    @category_configuration.assign_attributes(rdv_preferences_params)
    if @category_configuration.save
      render :update_rdv_preferences
    else
      turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
    end
  end

  def edit_messages; end

  def update_messages
    @category_configuration.assign_attributes(messages_params)
    if @category_configuration.save
      render :update_messages
    else
      turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
    end
  end

  def edit_notifications; end

  def update_notifications
    @category_configuration.assign_attributes(notifications_params)
    if @category_configuration.save
      render :update_notifications
    else
      turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
    end
  end

  def new_select_file_import
    set_file_selection_modal_context_for_new
  end

  def new_set_file_import
    if params[:file_configuration_id].blank?
      return turbo_stream_replace_error_list_with(["Veuillez sélectionner un modèle de fichier"])
    end

    @selected_file_configuration = FileConfiguration.find(params[:file_configuration_id])
  end

  def edit_file_import
    set_file_selection_modal_context_for_edit
  end

  # Uses params[:file_configuration_id] directly (not strong params) because the selection modal
  # uses radio_button_tag which sends the param at root level. Shared with new_set_file_import.
  def update_file_import
    if params[:file_configuration_id].blank?
      return turbo_stream_replace_error_list_with(["Veuillez sélectionner un modèle de fichier"])
    end

    @category_configuration.file_configuration_id = params[:file_configuration_id]
    @file_configuration = @category_configuration.file_configuration
    if @category_configuration.save
      render :update_file_import
    else
      turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
    end
  end

  private

  def category_configuration_params
    params.expect(category_configuration: PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def rdv_preferences_params
    params.expect(category_configuration: [{ invitation_formats: [] }, :convene_user, :rdv_with_referents,
                                           :phone_number])
  end

  def messages_params
    params.expect(category_configuration: [:invite_to_user_organisations_only,
                                           :number_of_days_before_invitations_expire])
  end

  def notifications_params
    params.expect(category_configuration: [:email_to_notify_rdv_changes, :email_to_notify_no_available_slots])
  end

  def create_configuration
    @create_configuration ||= CategoryConfigurations::Create.call(category_configuration: @category_configuration)
  end

  def set_category_configuration
    @category_configuration = @organisation.category_configurations.find(params[:id])
  end

  def set_file_configurations
    @file_configurations =
      FileConfiguration
      .preload(:organisations, category_configurations: [:motif_category, :organisation])
      .where(id: department_scope_file_configuration_ids + agent_scope_file_configuration_ids)
      .distinct.order(:created_at)
  end

  def department_scope_file_configuration_ids
    policy_scope(FileConfiguration)
      .joins(category_configurations: :organisation)
      .where(organisations: { department_id: current_department_id }).pluck(:id)
  end

  def agent_scope_file_configuration_ids
    policy_scope(FileConfiguration).where(created_by_agent: current_agent)
                                   .where.missing(:category_configurations)
                                   .pluck(:id)
  end

  def set_department
    @department = @organisation.department
  end

  def set_organisation
    @organisation = current_organisation
    authorize @organisation, :configure?
  end

  def set_available_motif_categories
    already_configured_ids = @organisation.category_configurations.pluck(:motif_category_id)
    @available_motif_categories = MotifCategoryPolicy.authorized_for_organisation(@organisation)
                                                     .where.not(id: already_configured_ids)
  end

  def set_file_selection_modal_context_for_edit
    @return_to_selection_path = edit_file_import_organisation_category_configuration_path(
      @organisation, @category_configuration
    )
    @current_file_configuration = @category_configuration.file_configuration
  end

  def set_file_selection_modal_context_for_new
    selected_id = params[:selected_file_configuration_id]
    @return_to_selection_path = new_select_file_import_organisation_category_configurations_path(
      @organisation, selected_file_configuration_id: selected_id
    )
    @current_file_configuration = selected_id ? FileConfiguration.find(selected_id) : nil
  end
end
