class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number
  ].freeze
  respond_to :json

  before_action :set_applicants, only: [:index]

  def index
    if fetch_rdv_solidarites_users.success?
      render json: { sucess: true, augmented_applicants: augmented_applicants }
    else
      render json: { success: false, errors: fetch_rdv_solidarites_users.errors }
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

  def fetch_rdv_solidarites_users
    @fetch_rdv_solidarites_users ||= FetchRdvSolidaritesUsers.call(
      ids: @applicants.pluck(:rdv_solidarites_user_id),
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_applicants
    @applicants = \
      if params[:uids].present?
        Applicant.where(uid: params[:uids])
      else
        Applicant.all
      end
  end

  def created_applicant
    create_applicant.applicant
  end
end
