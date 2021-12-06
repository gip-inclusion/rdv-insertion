class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :custom_id, :title, :status
  ].freeze
  before_action :set_organisation, only: [:index, :create, :show, :search, :update, :edit, :new]
  before_action :retrieve_applicants, only: [:search]
  before_action :set_applicant, only: [:show, :update, :edit]

  include FilterableApplicantsConcern

  def new
    @applicant = Applicant.new organisations: [@organisation]
    authorize @applicant
  end

  def create
    @applicant = Applicant.new(organisations: [@organisation], **applicant_params)
    authorize @applicant
    respond_to do |format|
      format.html { upsert_applicant_and_redirect(:new) }
      format.json { upsert_applicant_and_render }
    end
  end

  def index
    authorize @organisation, :list_applicants?
    @applicants = @organisation.applicants.includes(:invitations, :rdvs)
    @statuses_count = @applicants.group(:status).count
    filter_applicants
    @applicants = @applicants.order(created_at: :desc)

    # temporary solution to have up to date applicants with RDVS
    refresh_applicants
  end

  def show
    authorize @applicant
  end

  def search
    authorize @organisation, :list_applicants?
    # temporary solution to have up to date applicants with RDVS
    refresh_applicants
    render json: {
      success: true,
      applicants: @applicants
    }
  end

  def update
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

  def edit
    authorize @applicant
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS)
  end

  def upsert_applicant_and_redirect(page)
    if upsert_applicant.success?
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

  def refresh_applicants
    @refresh_applicants ||= RefreshApplicants.call(
      applicants: @applicants.to_a,
      rdv_solidarites_session: rdv_solidarites_session,
      rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
    )
  end

  def retrieve_applicants
    @applicants = @organisation.applicants.includes(:invitations, :rdvs)
                               .where(uid: params.require(:applicants).require(:uids))
                               .to_a
  end

  def set_organisation
    @organisation = Organisation.includes(:applicants, :configuration).find(params[:organisation_id])
  end

  def set_applicant
    @applicant = Applicant.find(params[:id])
  end
end
