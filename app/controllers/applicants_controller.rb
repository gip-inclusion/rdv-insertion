class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :custom_id, :title
  ].freeze
  respond_to :json

  before_action :retrieve_applicants, only: [:search]
  # temporary solution to have up to date applicants
  before_action :update_applicants, only: [:search]
  before_action :set_department, only: [:index, :create]

  def index
    authorize @department, :list_applicants?
    @configuration = @department.configuration
  end

  def search
    render json: {
      success: true,
      applicants: @applicants,
      next_page: update_applicants.next_page
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

  def update_applicants
    @update_applicants ||= UpdateApplicants.call(
      applicants: @applicants,
      rdv_solidarites_session: rdv_solidarites_session,
      page: params[:page]
    )
  end

  def retrieve_applicants
    @applicants = Applicant.includes(:department, :invitations)
                           .where(uid: params.require(:applicants).require(:uids))
                           .to_a
  end

  def set_department
    @department = Department.find(params[:department_id])
  end
end
