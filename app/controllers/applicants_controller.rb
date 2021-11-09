class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :custom_id, :title
  ].freeze
  before_action :set_organisation, only: [:index, :create, :show, :search, :update]
  before_action :retrieve_applicants, only: [:search]
  before_action :set_applicant, only: [:show, :update]

  include FilterableApplicantsConcern

  def create
    authorize @organisation, :create_applicant?
    if create_applicant.success?
      render json: { success: true, applicant: create_applicant.applicant }
    else
      render json: { success: false, errors: create_applicant.errors }
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
    authorize @applicant
    if @applicant.update(update_params)
      render json: { success: true }
    else
      render json: { success: false, errors: @applicant.errors.full_messages }
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS)
  end

  def update_params
    params.require(:applicant).permit(:status)
  end

  def create_applicant
    @create_applicant ||= CreateApplicant.call(
      applicant_data: applicant_params.to_h.deep_symbolize_keys,
      rdv_solidarites_session: rdv_solidarites_session,
      organisation: @organisation
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
