class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :custom_id, :title
  ].freeze
  before_action :retrieve_applicants, only: [:search]
  before_action :set_department, only: [:index, :create]
  before_action :set_applicant, only: [:show]

  include FilterableApplicantsConcern

  def index
    authorize @department, :list_applicants?
    @applicants = @department.applicants.includes(:invitations, :rdvs)
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
    authorize_applicants
    # temporary solution to have up to date applicants with RDVS
    refresh_applicants
    render json: {
      success: true,
      applicants: @applicants
    }
  end

  def create
    authorize @department, :create_applicant?
    if create_applicant.success?
      render json: { success: true, applicant: create_applicant.applicant }
    else
      render json: { success: false, errors: create_applicant.errors }
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS)
  end

  def create_applicant
    @create_applicant ||= CreateApplicant.call(
      applicant_data: applicant_params.to_h.deep_symbolize_keys,
      rdv_solidarites_session: rdv_solidarites_session,
      department: @department
    )
  end

  def refresh_applicants
    @refresh_applicants ||= RefreshApplicants.call(
      applicants: @applicants.to_a,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def authorize_applicants
    @applicants.each { |a| authorize a }
  end

  def retrieve_applicants
    @applicants = Applicant.includes(:department, :invitations, :rdvs)
                           .where(uid: params.require(:applicants).require(:uids))
                           .to_a
  end

  def set_department
    @department = Department.includes(:applicants, :configuration).find(params[:department_id])
  end

  def set_applicant
    @applicant = Applicant.find(params[:id])
  end
end
