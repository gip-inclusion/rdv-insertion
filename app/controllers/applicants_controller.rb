class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title, :status, :rights_opening_date
  ].freeze
  before_action :set_applicant, only: [:show, :update, :edit]
  before_action :set_context_variables, only: [:index, :new, :create, :show, :update, :edit]
  before_action :retrieve_applicants, only: [:search]

  include FilterableApplicantsConcern

  def new
    @applicant = Applicant.new department: @organisation.department, organisations: [@organisation]
    authorize @applicant
  end

  def create
    @applicant = Applicant.new(
      department: @organisation.department,
      organisations: [@organisation],
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
      **applicant_params
    )
    authorize @applicant
    respond_to do |format|
      format.html { save_applicant_and_redirect(:edit) }
      format.json { save_applicant_and_render }
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS)
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

  def set_context_variables
    department_level? ? set_department_variables : set_organisation_variables
  end

  def set_organisation_variables
    @organisation = Organisation.includes(:applicants, :configuration).find(params[:organisation_id])
    @department = @organisation.department
    @configuration = @organisation.configuration
  end

  def set_department_variables
    @department = Department.includes(:organisations, :applicants).find(params[:department_id])
    @organisation =  \
      if @applicant.blank?
        nil
      else
        policy_scope(Organisation).where(id: @applicant.organisations.pluck(:id), department: @department).first
      end
    @configuration = @department.configuration
  end

  def retrieve_applicants
    @applicants = policy_scope(Applicant).includes(:organisations, :invitations, :rdvs)
                                         .where(uid: params.require(:applicants).require(:uids))
                                         .to_a
  end
end
