class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number
  ].freeze
  respond_to :json

  before_action :retrieve_applicants, only: [:augment]

  def augment
    if augment_applicants.success?
      render json: { sucess: true, augmented_applicants: augment_applicants.augmented_applicants }
    else
      render json: { success: false, errors: augment_applicants.errors }
    end
  end

  def create
    if create_applicant.success?
      render json: { success: true, rdv_solidarites_user: create_applicant.rdv_solidarites_user }
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
      applicant_data: applicant_params.to_h.with_indifferent_access,
      rdv_solidarites_session: rdv_solidarites_session,
      agent: current_agent
    )
  end

  def augment_applicants
    @augment_applicants ||= AugmentApplicants.call(
      applicants: @applicants,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def retrieve_applicants
    params.require(:uids)
    @applicants = Applicant.where(uid: params[:uids])
  end
end
