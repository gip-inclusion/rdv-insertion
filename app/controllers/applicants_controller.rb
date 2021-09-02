class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :custom_id
  ].freeze
  respond_to :json

  before_action :retrieve_applicants, only: [:search]
  before_action :set_department, only: [:index, :create]

  def index
    authorize @department, :list_applicants?
    @configuration = @department.configuration
  end

  def search
    if retrieve_augmented_applicants.success?
      render json: {
        success: true,
        augmented_applicants: retrieve_augmented_applicants.augmented_applicants,
        next_page: retrieve_augmented_applicants.next_page
      }
    else
      render json: { success: false, errors: retrieve_augmented_applicants.errors }
    end
  end

  def create
    authorize @department, :create_applicant?
    if create_applicant.success?
      render json: { success: true, augmented_applicant: create_applicant.augmented_applicant }
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

  def retrieve_augmented_applicants
    @retrieve_augmented_applicants ||= RetrieveAugmentedApplicants.call(
      applicants: @applicants,
      rdv_solidarites_session: rdv_solidarites_session,
      page: params[:page]
    )
  end

  def retrieve_applicants
    @applicants = Applicant.includes(:department)
                           .where(uid: params.require(:applicants).require(:uids))
                           .to_a
  end

  def set_department
    @department = Department.find(params[:department_id])
  end
end
