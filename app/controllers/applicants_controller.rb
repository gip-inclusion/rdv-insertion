# rubocop:disable Metrics/ClassLength

class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :nir, :pole_emploi_id, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title,
    :status, :rights_opening_date, { rdv_contexts_attributes: [:motif_category_id] }
  ].freeze

  include SetOrganisationAndDepartmentConcern
  include SetAllConfigurationsConcern
  include SetCurrentAgentRolesConcern
  include BackToListConcern
  include Applicants::Filterable
  include ResourcesLists::Extractable

  before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                :set_current_agent_roles, :set_applicants, :filter_applicants, :order_applicants,
                :store_back_to_list_url, :set_back_to_list_url, :set_extraction_url,
                for: :index
  before_action :set_applicant, :set_organisation, :set_department, :set_all_configurations,
                :set_applicant_organisations, :set_applicant_rdv_contexts, :set_applicant_archive,
                :set_convocation_motifs_by_rdv_context, :set_back_to_list_url,
                for: :show
  before_action :set_organisation, :set_department, :set_organisations, :set_back_to_list_url,
                for: [:new, :create]
  before_action :set_applicant, :set_organisation, :set_department,
                for: [:edit, :update]

  def index
    respond_to do |format|
      format.html
      format.csv { send_csv }
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
    authorize @organisation, :add_applicant?
    @applicant = find_or_initialize_applicant.applicant
    # TODO: if an applicant exists, return it to the agent to let him decide what to do
    @applicant.assign_attributes(**applicant_params.compact_blank)
    respond_to do |format|
      format.html { save_applicant_and_redirect(:new) }
      format.json { save_applicant_and_render }
    end
  end

  def update
    @applicant.assign_attributes(**formatted_params)
    authorize @applicant
    respond_to do |format|
      format.html { save_applicant_and_redirect(:edit) }
      format.json { save_applicant_and_render }
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_params
    # we nullify some blank params for unicity exceptions (ActiveRecord::RecordNotUnique) not to raise
    applicant_params.to_h do |k, v|
      [k, k.in?([:affiliation_number, :department_internal_id, :email, :pole_emploi_id, :nir]) ? v.presence : v]
    end
  end

  def find_or_initialize_applicant
    @find_or_initialize_applicant ||= Applicants::FindOrInitialize.call(
      applicant_attributes: applicant_params,
      department_id: @department.id
    )
  end

  def save_applicant_and_redirect(page)
    if save_applicant.success?
      redirect_to(after_save_path)
    else
      flash.now[:error] = save_applicant.errors&.join(",")
      render page, status: :unprocessable_entity
    end
  end

  def save_applicant_and_render
    if save_applicant.success?
      render json: { success: true, applicant: @applicant }
    else
      render json: { success: false, errors: save_applicant.errors }, status: :unprocessable_entity
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
    @applicants = policy_scope(Applicant)
                  .preload(rdv_contexts: [:invitations])
                  .active.distinct
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def set_convocation_motifs_by_rdv_context
    return if @all_configurations.none?(&:convene_applicant?)

    convocation_motifs = Motif.includes(:organisation).active.where(
      organisation_id: @applicant_organisations.ids, motif_category: @all_configurations.map(&:motif_category)
    ).select(&:convocation?)

    @convocation_motifs_by_rdv_context = @rdv_contexts.index_with do |rdv_context|
      organisation_ids = department_level? ? @applicant_organisations.ids : [@organisation.id]
      convocation_motifs.find do |motif|
        motif.motif_category_id == rdv_context.motif_category_id &&
          motif.organisation_id.in?(organisation_ids)
      end
    end
  end

  def order_applicants
    @applicants = @applicants.order(created_at: :desc)
  end

  def after_save_path
    return department_applicant_path(@department, @applicant) if department_level?

    organisation_applicant_path(@organisation, @applicant)
  end
end

# rubocop: enable Metrics/ClassLength
