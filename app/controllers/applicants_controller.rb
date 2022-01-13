class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title, :status, :rights_opening_date
  ].freeze
  before_action :set_organisation, only: [:index, :create, :show, :update, :edit, :new]
  before_action :set_department, only: [:index, :show, :edit, :update]
  before_action :retrieve_applicants, only: [:search]
  before_action :set_applicant, only: [:show, :update, :edit]

  include FilterableApplicantsConcern

  def new
    @applicant = Applicant.new department: @organisation.department, organisations: [@organisation]
    authorize @applicant
  end

  def create
    @applicant = Applicant.new(
      department: @organisation.department,
      organisations: [@organisation],
      **applicant_params
    )
    authorize @applicant
    respond_to do |format|
      format.html { upsert_applicant_and_redirect(:new) }
      format.json { upsert_applicant_and_render }
    end
  end

  def index
    @applicants = policy_scope(Applicant).includes(:invitations, :rdvs)
    @applicants = if @organisation
                    @applicants.where(organisations: @organisation)
                  else
                    @applicants.where(organisations: policy_scope(Organisation).where(department: @department))
                  end
    @search_url = @organisation ? organisation_applicants_path(@organisation) : department_applicants_path(@department)
    @configuration = @organisation ? @organisation.configuration : @department.configuration
    @statuses_count = @applicants.group(:status).count
    filter_applicants
    @applicants = @applicants.order(created_at: :desc)
  end

  def show
    authorize @applicant
    set_organisation_when_department_level if @organisation.nil?
  end

  def search
    render json: {
      success: true,
      applicants: @applicants
    }
  end

  def edit
    authorize @applicant
    set_organisation_when_department_level if @organisation.nil?
  end

  def update
    set_organisation_when_department_level if @organisation.nil?
    @applicant.assign_attributes(
      organisations: (@applicant.organisations.to_a + [@organisation]).uniq,
      **applicant_params
    )
    authorize @applicant
    respond_to do |format|
      format.html { upsert_applicant_and_redirect(:edit) }
      format.json { upsert_applicant_and_render }
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS)
  end

  def upsert_applicant_and_redirect(page)
    if @department_level && upsert_applicant.success?
      redirect_to department_applicant_path(@department, @applicant)
    elsif upsert_applicant.success?
      redirect_to organisation_applicant_path(@organisation, @applicant)
    else
      flash.now[:error] = upsert_applicant.errors&.join(',')
      render page
    end
  end

  def upsert_applicant_and_render
    if upsert_applicant.success?
      render json: { success: true, applicant: @applicant }
    else
      render json: { success: false, errors: upsert_applicant.errors }
    end
  end

  def upsert_applicant
    @upsert_applicant ||= UpsertApplicant.call(
      applicant: @applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def retrieve_applicants
    @applicants = policy_scope(Applicant).includes(:organisations, :invitations, :rdvs)
                                         .where(uid: params.require(:applicants).require(:uids))
                                         .to_a
  end

  def set_organisation
    return unless params[:organisation_id]

    @organisation = Organisation.includes(:applicants, :configuration).find(params[:organisation_id])
  end

  def set_department
    @department = @organisation&.department || Department.includes(:organisations, :applicants)
                                                         .find(params[:department_id])
  end

  def set_organisation_when_department_level
    # We consider that an applicant is only in one organisation per department
    @organisation = @applicant.organisations.where(department: @department).first
    @department_level = true
  end

  def set_applicant
    @applicant = Applicant.includes(:organisations).find(params[:id])
  end
end
