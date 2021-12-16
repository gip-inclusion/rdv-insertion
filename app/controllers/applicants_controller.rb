class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :custom_id, :title, :status, :rights_opening_date
  ].freeze
  before_action :set_organisation, only: [:index, :create, :show, :update, :edit, :new]
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
    @applicants = policy_scope(Applicant).includes(:invitations, :rdvs)
                                         .where(organisations: @organisation)
    @statuses_count = @applicants.group(:status).count
    filter_applicants
    @applicants = @applicants.order(created_at: :desc)
  end

  def show
    authorize @applicant
  end

  def search
    render json: {
      success: true,
      applicants: @applicants
    }
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
      format.html { upsert_applicant_and_redirect(:edit) }
      format.json { upsert_applicant_and_render }
    end
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

  def retrieve_applicants
    @applicants = policy_scope(Applicant).includes(:organisations, :invitations, :rdvs)
                                         .where(uid: params.require(:applicants).require(:uids))
                                         .to_a
  end

  def set_organisation
    @organisation = Organisation.includes(:applicants, :configuration).find(params[:organisation_id])
  end

  def set_applicant
    @applicant = Applicant.includes(:organisations).find(params[:id])
  end
end
