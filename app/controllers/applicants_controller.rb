# rubocop:disable Metrics/ClassLength

class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :nir, :pole_emploi_id, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title, :encrypted_id,
    :status, :rights_opening_date, :archiving_reason
  ].freeze

  include BackToListConcern
  include Applicants::Filterable
  include Applicants::Convocable

  before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                :set_current_agent_roles, :set_applicants_scope,
                :set_current_configuration, :set_current_motif_category,
                :set_applicants, :set_rdv_contexts,
                :filter_applicants, :order_applicants,
                :set_convocation_motifs_by_applicant,
                for: :index
  before_action :set_applicant, :set_organisation, :set_department, :set_all_configurations,
                :set_applicant_organisations, :set_applicant_rdv_contexts,
                :set_convocation_motifs_by_rdv_context,
                :set_back_to_applicants_list_url,
                for: :show
  before_action :set_organisation, :set_department, :set_organisations,
                for: [:new, :create]
  before_action :set_applicant, :set_organisation, :set_department,
                for: [:edit, :update]
  before_action :process_input!, only: :create
  after_action :store_back_to_applicants_list_url, only: [:index]

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
    @applicant = process_input.matching_applicant || Applicant.new
    @applicant.assign_attributes(**applicant_attributes.compact_blank)
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

  def applicant_attributes
    applicant_params.slice(*Applicant.attribute_names.map(&:to_sym))
  end

  def formatted_attributes
    # we nullify some blank params for unicity exceptions (ActiveRecord::RecordNotUnique) not to raise
    applicant_attributes.to_h do |k, v|
      [k, k.in?([:affiliation_number, :department_internal_id, :email, :pole_emploi_id, :nir]) ? v.presence : v]
    end
  end

  def process_input!
    return if process_input.success?
    return render_create_or_update_choice(process_input.contact_duplicate, process_input.duplicate_attribute) \
       if process_input.contact_duplicate

    @applicant = process_input.matching_applicant
    render_errors(process_input.errors)
  end

  def process_input
    @process_input ||= Applicants::ProcessInput.call(
      applicant_params: applicant_params,
      department_id: @department.id
    )
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

  def render_create_or_update_choice(contact_duplicate, duplicate_attribute)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "remote_modal", partial: "create_or_update_choice", locals: {
            contact_duplicate: contact_duplicate,
            duplicate_attribute: duplicate_attribute,
            encrypted_id: EncryptionHelper.encrypt(contact_duplicate.id),
            applicant_attributes: applicant_attributes,
            department: @department,
            organisation: @organisation
          }
        )
      end
      format.json do
        render json: {
          success: false,
          contact_duplicate: contact_duplicate,
          duplicate_attribute: duplicate_attribute,
          encrypted_id: EncryptionHelper.encrypt(contact_duplicate.id)
        }, status: :unprocessable_entity
      end
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

    @current_configuration =
      if params[:motif_category_id].present?
        @all_configurations.find { |c| c.motif_category_id == params[:motif_category_id].to_i }
      else
        @all_configurations.first
      end
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

  def set_applicant_organisations
    @applicant_organisations =
      policy_scope(Organisation).where(id: @applicant.organisation_ids, department: @department)
  end

  def set_applicants
    archived_scope? ? set_archived_applicants : set_applicants_for_motif_category
  end

  def set_applicants_for_motif_category
    @applicants = policy_scope(Applicant)
                  .preload(
                    :organisations,
                    rdv_contexts: [:notifications, :invitations]
                  )
                  .active.distinct.archived(false)
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
                  .joins(:rdv_contexts)
                  .where(rdv_contexts: { motif_category: @current_motif_category })
  end

  def set_archived_applicants
    @applicants = policy_scope(Applicant)
                  .active.distinct.archived
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
    @applicants = archived_scope? ? @applicants.order(archived_at: :desc) : @applicants.order(created_at: :desc)
  end

  def after_save_path
    return department_applicant_path(@department, @applicant) if department_level?

    organisation_applicant_path(@organisation, @applicant)
  end
end

# rubocop: enable Metrics/ClassLength
