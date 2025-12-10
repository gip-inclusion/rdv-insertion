class CategoryConfigurationsController < ApplicationController
  PERMITTED_PARAMS = [
    { invitation_formats: [] }, :convene_user, :rdv_with_referents, :file_configuration_id,
    :invite_to_user_organisations_only, :number_of_days_before_invitations_expire, :motif_category_id,
    :template_rdv_title_override, :template_rdv_title_by_phone_override, :template_rdv_purpose_override,
    :template_user_designation_override, :phone_number,
    :email_to_notify_no_available_slots, :email_to_notify_rdv_changes
  ].freeze

  before_action :set_organisation, only: [:new, :create, :show, :edit, :update, :destroy,
                                          :edit_rdv_preferences, :update_rdv_preferences,
                                          :edit_messages, :update_messages,
                                          :edit_notifications, :update_notifications]
  before_action :set_category_configuration, :set_file_configuration, :set_template,
                only: [:show, :edit, :update, :destroy,
                       :edit_rdv_preferences, :update_rdv_preferences,
                       :edit_messages, :update_messages,
                       :edit_notifications, :update_notifications]
  before_action :set_department, :set_file_configurations, :set_authorized_motif_categories,
                only: [:new, :create, :edit, :update]

  def index
    # We keep this action to redirect to the new /configuration page in case this url was saved by the agent
    redirect_to organisation_configuration_path(params[:organisation_id])
  end

  def show; end

  def new
    @category_configuration = CategoryConfiguration.new(organisation: @organisation)
    render layout: "no_footer_white_bg"
  end

  def edit; end

  def create
    @category_configuration = CategoryConfiguration.new(organisation: @organisation)
    @category_configuration.assign_attributes(**category_configuration_params.compact_blank)
    if create_configuration.success?
      flash[:success] = "La configuration a été créée avec succès"
      redirect_to organisation_configuration_categories_path(@organisation)
    else
      flash.now[:error] = create_configuration.errors.join(",")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @category_configuration.assign_attributes(**formatted_configuration_params)
    if @category_configuration.save
      flash.now[:success] = "La configuration a été modifiée avec succès"
      redirect_to organisation_category_configuration_path(@organisation, @category_configuration)
    else
      flash.now[:error] = @category_configuration.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category_configuration.destroy!
    flash.now[:success] = "La configuration a été supprimée avec succès"
    respond_to :turbo_stream
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

  def formatted_configuration_params
    category_configuration_params.to_h do |k, v|
      [k, k.to_s.include?("override") ? v.presence : v]
    end
  end

  def create_configuration
    @create_configuration ||= CategoryConfigurations::Create.call(category_configuration: @category_configuration)
  end

  def set_category_configuration
    @category_configuration = @organisation.category_configurations.find(params[:id])
  end

  def set_file_configuration
    @file_configuration = @category_configuration.file_configuration
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

  def set_template
    @template = @category_configuration.template
  end

  def set_department
    @department = @organisation.department
  end

  def set_organisation
    @organisation = current_organisation
    authorize @organisation, :configure?
  end

  def set_authorized_motif_categories
    @authorized_motif_categories = MotifCategoryPolicy.authorized_for_organisation(@organisation)
  end
end
