# rubocop:disable Metrics/ClassLength

class UsersController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :nir, :pole_emploi_id, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title, :orientation,
    :status, :rights_opening_date,
    { rdv_contexts_attributes: [:motif_category_id], tag_users_attributes: [:tag_id] }
  ].freeze

  include BackToListConcern
  include Users::Filterable
  include Users::Sortable

  before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                :set_current_agent_roles, :set_users_scope,
                :set_current_configuration, :set_current_motif_category,
                :set_users, :set_rdv_contexts,
                :filter_users, :order_users,
                for: :index
  before_action :set_user, :set_organisation, :set_department, :set_all_configurations,
                :set_user_organisations, :set_user_rdv_contexts, :set_user_archive,
                :set_back_to_users_list_url,
                for: :show
  before_action :set_organisation, :set_department, :set_organisations,
                for: [:new, :create]
  before_action :set_user, :set_organisation, :set_department,
                for: [:edit, :update]
  before_action :find_or_initialize_user!, only: :create
  before_action :reset_tag_users, only: :update
  after_action :store_back_to_users_list_url, only: [:index]

  def default_list
    redirect_to default_list_path
  end

  def index
    respond_to do |format|
      format.html
      format.csv { send_users_csv }
    end
  end

  def show; end

  def new
    @user = User.new
    authorize @user
  end

  def edit
    authorize @user
  end

  def create
    @user.assign_attributes(**formatted_attributes.compact_blank)
    if save_user.success?
      render_save_user_success
    else
      render_errors(save_user.errors)
    end
  end

  def update
    @user.assign_attributes(**formatted_attributes)
    authorize @user
    if save_user.success?
      render_save_user_success
    else
      render_errors(save_user.errors)
    end
  end

  private

  def user_params
    params.require(:user).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_attributes
    # we nullify some blank params for unicity exceptions (ActiveRecord::RecordNotUnique) not to raise
    user_params.to_h do |k, v|
      [k, k.in?([:affiliation_number, :department_internal_id, :email, :pole_emploi_id, :nir]) ? v.presence : v]
    end
  end

  def reset_tag_users
    # since we send the exhaustive list of tags, we need to reset the tag_users list
    # if tag_users_attributes is nil, it means that the user did not change the tags
    @user.tag_users.destroy_all unless params[:user][:tag_users_attributes].nil?
  end

  def send_users_csv
    send_data generate_users_csv.csv, filename: generate_users_csv.filename
  end

  def generate_users_csv
    @generate_users_csv ||= Exporters::GenerateUsersCsv.call(
      users: @users,
      structure: department_level? ? @department : @organisation,
      motif_category: @current_motif_category
    )
  end

  def find_or_initialize_user!
    @user = find_or_initialize_user.user
    render_errors(find_or_initialize_user.errors) if find_or_initialize_user.failure?
  end

  def find_or_initialize_user
    @find_or_initialize_user ||= Users::FindOrInitialize.call(
      attributes: formatted_attributes, department_id: @department.id
    )
  end

  def render_errors(errors)
    respond_to do |format|
      flash.now[:error] = errors.join(",")
      format.html do
        render(action_name == "update" ? :edit : :new, status: :unprocessable_entity)
      end
      format.turbo_stream
      format.json { render json: { success: false, errors: errors }, status: :unprocessable_entity }
    end
  end

  def render_save_user_success
    respond_to do |format|
      format.html { redirect_to(after_save_path) }
      format.json { render json: { success: true, user: @user } }
      format.turbo_stream { flash.now[:success] = "Usager mis à jour avec succès" }
    end
  end

  def save_user
    @save_user ||= Users::Save.call(
      user: @user,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_user
    @user =
      policy_scope(User)
      .preload(:invitations, organisations: [:department, :configurations])
      .where(
        if department_level?
          { organisations: { department_id: params[:department_id] } }
        else
          { organisations: params[:organisation_id] }
        end
      )
      .find(params[:id])
  end

  def set_organisation
    @organisation =
      if department_level?
        set_organisation_at_department_level
      else
        policy_scope(Organisation).find(params[:organisation_id])
      end
  end

  def set_organisation_at_department_level
    return set_organisation_through_form if params[:action] == "create"
    return if @user.nil? # no need to set an organisation if we are not in an user-level page

    @organisation = policy_scope(Organisation)
                    .find_by(id: @user.organisation_ids, department_id: params[:department_id])
  end

  def set_organisation_through_form
    # for now we allow only one organisation through creation
    @organisation = Organisation.find_by(
      id: params[:user][:organisation_ids], department_id: params[:department_id]
    )
  end

  def set_organisations
    @organisations = policy_scope(Organisation).where(department: @department)
  end

  def set_department
    @department =
      if department_level?
        policy_scope(Department).find(params[:department_id])
      else
        @organisation.department
      end
  end

  def set_all_configurations
    @all_configurations =
      if department_level?
        (policy_scope(::Configuration).includes(:motif_category) & @department.configurations).uniq(&:motif_category_id)
      else
        @organisation.configurations.includes(:motif_category)
      end
    @all_configurations = @all_configurations.sort_by(&:motif_category_position)
  end

  def set_current_configuration
    return if archived_scope?
    return unless params[:motif_category_id]

    @current_configuration =
      @all_configurations.find { |c| c.motif_category_id == params[:motif_category_id].to_i }
  end

  def set_current_motif_category
    @current_motif_category = @current_configuration&.motif_category
  end

  def set_user_rdv_contexts
    @rdv_contexts =
      RdvContext.preload(
        :invitations, :motif_category,
        participations: [:notifications, { rdv: [:motif, :organisation] }]
      ).where(
        user: @user, motif_category: @all_configurations.map(&:motif_category)
      ).sort_by(&:motif_category_position)
  end

  def set_user_archive
    @archive = Archive.find_by(user: @user, department: @department)
  end

  def set_user_organisations
    @user_organisations =
      policy_scope(Organisation).where(id: @user.organisation_ids, department: @department)
  end

  def set_users
    if archived_scope?
      set_archived_users
    elsif @current_motif_category
      set_users_for_motif_category
    else
      set_all_users
    end
  end

  def set_all_users
    @users = policy_scope(User)
             .preload(rdv_contexts: [:invitations])
             .active
             .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def set_users_for_motif_category
    @users = policy_scope(User)
             .preload(rdv_contexts: [:notifications, :invitations])
             .active
             .select("DISTINCT(users.id), users.*, rdv_contexts.created_at")
             .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
             .where.not(id: @department.archived_users.ids)
             .joins(:rdv_contexts)
             .where(rdv_contexts: { motif_category: @current_motif_category })
             .where.not(rdv_contexts: { status: "closed" })
  end

  def set_archived_users
    @users = policy_scope(User)
             .includes(:archives)
             .preload(:invitations, :participations)
             .active.distinct
             .where(id: @department.archived_users)
             .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def set_rdv_contexts
    return if archived_scope?

    @rdv_contexts = RdvContext.where(
      user_id: @users.ids, motif_category: @current_motif_category
    )
    @statuses_count = @rdv_contexts.group(:status).count
  end

  def set_current_agent_roles
    @current_agent_roles = AgentRole.where(
      department_level? ? { organisation: @organisations } : { organisation: @organisation }, agent: current_agent
    )
  end

  def set_users_scope
    @users_scope = params[:users_scope]
  end

  def archived_scope?
    @users_scope == "archived"
  end

  def after_save_path
    return department_user_path(@department, @user) if department_level?

    organisation_user_path(@organisation, @user)
  end

  def default_list_path # rubocop:disable Metrics/AbcSize
    structure = if department_level?
                  Department.includes(:motif_categories).find(params[:department_id])
                else
                  Organisation.includes(:motif_categories).find(params[:organisation_id])
                end
    path = department_level? ? department_users_path(structure) : organisation_users_path(structure)
    return path if structure.motif_categories.blank? || structure.motif_categories.count > 1

    "#{path}?motif_category_id=#{structure.motif_categories.first.id}"
  end
end

# rubocop: enable Metrics/ClassLength
