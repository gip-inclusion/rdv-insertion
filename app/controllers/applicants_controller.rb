# rubocop:disable Metrics/ClassLength

class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :nir, :pole_emploi_id, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title,
    :status, :rights_opening_date, { rdv_contexts_attributes: [:motif_category_id] }
  ].freeze

  include BackToListConcern
  include Applicants::Filterable

  before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                :set_current_agent_roles, :set_applicants_scope,
                :set_current_configuration, :set_current_motif_category,
                :set_applicants, :set_rdv_contexts,
                :filter_applicants, :order_applicants,
                for: :index
  before_action :set_applicant, :set_organisation, :set_department, :set_all_configurations,
                :set_applicant_organisations, :set_applicant_rdv_contexts, :set_applicant_archive,
                :set_back_to_applicants_list_url,
                for: :show
  before_action :set_organisation, :set_department, :set_organisations,
                for: [:new, :create]
  before_action :set_applicant, :set_organisation, :set_department,
                for: [:edit, :update]
  before_action :find_or_initialize_applicant!, only: :create
  after_action :store_back_to_applicants_list_url, only: [:index]

  def default_list
    redirect_to default_list_path
  end

  def index
    respond_to do |format|
      format.html
      format.csv { send_applicants_csv }
    end
  end

  def show; end

  def new
    @applicant = Applicant.new
    authorize @applicant
  end

  def edit
    authorize @applicant
  end

  def create
    @applicant.assign_attributes(**formatted_attributes.compact_blank)
    if save_applicant.success?
      render_save_applicant_success
    else
      render_errors(save_applicant.errors)
    end
  end

  def update
    @applicant.assign_attributes(**formatted_attributes)
    authorize @applicant
    if save_applicant.success?
      render_save_applicant_success
    else
      render_errors(save_applicant.errors)
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_attributes
    # we nullify some blank params for unicity exceptions (ActiveRecord::RecordNotUnique) not to raise
    applicant_params.to_h do |k, v|
      [k, k.in?([:affiliation_number, :department_internal_id, :email, :pole_emploi_id, :nir]) ? v.presence : v]
    end
  end

  def send_applicants_csv
    send_data generate_applicants_csv.csv, filename: generate_applicants_csv.filename
  end

  def generate_applicants_csv
    @generate_applicants_csv ||= Exporters::GenerateApplicantsCsv.call(
      applicants: @applicants,
      structure: department_level? ? @department : @organisation,
      motif_category: @current_motif_category
    )
  end

  def find_or_initialize_applicant!
    @applicant = find_or_initialize_applicant.applicant
    render_errors(find_or_initialize_applicant.errors) if find_or_initialize_applicant.failure?
  end

  def find_or_initialize_applicant
    @find_or_initialize_applicant ||= Applicants::FindOrInitialize.call(
      attributes: formatted_attributes, department_id: @department.id
    )
  end

  def render_errors(errors)
    respond_to do |format|
      format.html do
        flash.now[:error] = errors.join(",")
        render(action_name == "update" ? :edit : :new, status: :unprocessable_entity)
      end
      format.json { render json: { success: false, errors: errors }, status: :unprocessable_entity }
    end
  end

  def render_save_applicant_success
    respond_to do |format|
      format.html { redirect_to(after_save_path) }
      format.json { render json: { success: true, applicant: @applicant } }
    end
  end

  def save_applicant
    @save_applicant ||= Applicants::Save.call(
      applicant: @applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_applicant
    @applicant =
      policy_scope(Applicant)
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
    return if @applicant.nil? # no need to set an organisation if we are not in an applicant-level page

    @organisation = policy_scope(Organisation)
                    .find_by(id: @applicant.organisation_ids, department_id: params[:department_id])
  end

  def set_organisation_through_form
    # for now we allow only one organisation through creation
    @organisation = Organisation.find_by(
      id: params[:applicant][:organisation_ids], department_id: params[:department_id]
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

  def set_applicant_rdv_contexts
    @rdv_contexts =
      RdvContext.preload(
        :invitations, :motif_category,
        participations: [:notifications, { rdv: [:motif, :organisation] }]
      ).where(
        applicant: @applicant, motif_category: @all_configurations.map(&:motif_category)
      ).sort_by(&:motif_category_position)
  end

  def set_applicant_archive
    @archive = Archive.find_by(applicant: @applicant, department: @department)
  end

  def set_applicant_organisations
    @applicant_organisations =
      policy_scope(Organisation).where(id: @applicant.organisation_ids, department: @department)
  end

  def set_applicants
    if archived_scope?
      set_archived_applicants
    elsif @current_motif_category
      set_applicants_for_motif_category
    else
      set_all_applicants
    end
  end

  def set_all_applicants
    @applicants = policy_scope(Applicant)
                  .preload(rdv_contexts: [:invitations])
                  .active.distinct
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def set_applicants_for_motif_category
    @applicants = policy_scope(Applicant)
                  .preload(rdv_contexts: [:notifications, :invitations])
                  .active.distinct
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
                  .where.not(id: @department.archived_applicants.ids)
                  .joins(:rdv_contexts)
                  .where(rdv_contexts: { motif_category: @current_motif_category })
                  .where.not(rdv_contexts: { status: "closed" })
  end

  def set_archived_applicants
    @applicants = policy_scope(Applicant)
                  .includes(:archives)
                  .preload(:invitations, :participations)
                  .active.distinct
                  .where(id: @department.archived_applicants)
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def set_rdv_contexts
    return if archived_scope?

    @rdv_contexts = RdvContext.where(
      applicant_id: @applicants.ids, motif_category: @current_motif_category
    )
    @statuses_count = @rdv_contexts.group(:status).count
  end

  def set_current_agent_roles
    @current_agent_roles = AgentRole.where(
      department_level? ? { organisation: @organisations } : { organisation: @organisation }, agent: current_agent
    )
  end

  def set_applicants_scope
    @applicants_scope = params[:applicants_scope]
  end

  def archived_scope?
    @applicants_scope == "archived"
  end

  def order_applicants
    @applicants = archived_scope? ? @applicants.order("archives.created_at desc") : @applicants.order(created_at: :desc)
  end

  def after_save_path
    return department_applicant_path(@department, @applicant) if department_level?

    organisation_applicant_path(@organisation, @applicant)
  end

  def default_list_path # rubocop:disable Metrics/AbcSize
    structure = if department_level?
                  Department.includes(:motif_categories).find(params[:department_id])
                else
                  Organisation.includes(:motif_categories).find(params[:organisation_id])
                end
    path = department_level? ? department_applicants_path(structure) : organisation_applicants_path(structure)
    return path if structure.motif_categories.blank? || structure.motif_categories.count > 1

    "#{path}?motif_category_id=#{structure.motif_categories.first.id}"
  end
end

# rubocop: enable Metrics/ClassLength
