# rubocop:disable Metrics/ClassLength

class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title,
    :status, :rights_opening_date, :archiving_reason, :is_archived
  ].freeze
  before_action :set_applicant, only: [:show, :update, :edit]
  before_action :set_variables, only: [:index, :new, :create, :show, :update, :edit]
  before_action :retrieve_applicants, only: [:search]

  include FilterableApplicantsConcern

  def new
    @applicant = Applicant.new department: @organisation.department, organisations: [@organisation]
    authorize @applicant
  end

  def create
    @applicant = find_or_initialize_applicant.applicant
    # TODO: if an applicant exists, return it to the agent to let him decide what to do
    @applicant.assign_attributes(
      department: @organisation.department,
      organisations: (@applicant.organisations.to_a + [@organisation]).uniq,
      **applicant_params.compact_blank
    )
    authorize @applicant
    respond_to do |format|
      format.html { save_applicant_and_redirect(:new) }
      format.json { save_applicant_and_render }
    end
  end

  def index
    @applicants = policy_scope(Applicant).includes(:invitations, :rdvs).distinct
    @applicants = \
      if department_level?
        @applicants.where(organisations: policy_scope(Organisation).where(department: @department))
      else
        @applicants.where(organisations: @organisation)
      end
    @statuses_count = @applicants.group(:status).count
    filter_applicants
    @applicants = @applicants.order(created_at: :desc)
  end

  def show
    authorize @applicant
  end

  def search
    render json: { success: true, applicants: @applicants }
  end

  def edit
    authorize @applicant
  end

  def update
    @applicant.assign_attributes(
      organisations: (@applicant.organisations.to_a + [@organisation]).uniq,
      **formatted_params
    )
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
      [k, k.in?([:affiliation_number, :department_internal_id]) ? v.presence : v]
    end
  end

  def find_or_initialize_applicant
    @find_or_initialize_applicant ||= FindOrInitializeApplicant.call(
      department_internal_id: applicant_params[:department_internal_id],
      role: applicant_params[:role],
      affiliation_number: applicant_params[:affiliation_number],
      department_id: @department.id
    )
  end

  def save_applicant_and_redirect(page)
    if save_applicant.success?
      redirect_to(after_save_path)
    else
      flash.now[:error] = save_applicant.errors&.join(',')
      render page
    end
  end

  def save_applicant_and_render
    if save_applicant.success?
      render json: { success: true, applicant: @applicant }
    else
      render json: { success: false, errors: save_applicant.errors }
    end
  end

  def save_applicant
    @save_applicant ||= SaveApplicant.call(
      applicant: @applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_applicant
    @applicant = Applicant.includes(:organisations).find(params[:id])
  end

  def after_save_path
    return department_applicant_path(@department, @applicant) if department_level?

    organisation_applicant_path(@organisation, @applicant)
  end

  def set_variables
    department_level? ? set_department_variables : set_organisation_variables
  end

  def set_organisation_variables
    @organisation = policy_scope(Organisation).includes(:applicants, :configurations).find(params[:organisation_id])
    @department = @organisation.department
    @configuration = @organisation.configurations.first
  end

  def set_department_variables
    @department = Department.includes(:organisations, :applicants).find(params[:department_id])
    @configuration = (policy_scope(::Configuration) & @department.configurations).first
    set_organisation_at_department_level if @applicant.present?
  end

  def set_organisation_at_department_level
    # If an applicant has rdvs, we want the "Voir sur RDV-Solidarités" button to redirect
    # to the organisation to which the last appointment belongs
    authorized_organisations_with_rdvs = \
      @applicant.organisations_with_rdvs & policy_scope(Organisation).where(department: @department)
    @organisation = \
      authorized_organisations_with_rdvs.last ||
      policy_scope(Organisation).where(id: @applicant.organisations.pluck(:id), department: @department).first
  end

  def retrieve_applicants
    @applicants = policy_scope(Applicant).includes(:organisations, :invitations, :rdvs).distinct
    @applicants = @applicants
                  .where(department_internal_id: params.require(:applicants)[:department_internal_ids])
                  .or(@applicants.where(uid: params.require(:applicants)[:uids]))
                  .to_a
  end
end

# rubocop: enable Metrics/ClassLength
