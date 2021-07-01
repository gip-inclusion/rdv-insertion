class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number
  ].freeze
  respond_to :json

  before_action :retrieve_applicants, only: [:search]

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
      agent: current_agent
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
    @applicants = Applicant.where(uid: params.require(:applicants).require(:uids))
  end
end
