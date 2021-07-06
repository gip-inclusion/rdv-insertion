class InvitationsController < ApplicationController
  before_action :set_applicant
  respond_to :json

  def create
    if invite_applicant.success?
      render json: { success: true, invitation: invite_applicant.invitation }
    else
      render json: { success: false, errors: invite_applicant.errors }
    end
  end

  private

  def set_applicant
    @applicant = Applicant.find(params[:applicant_id])
  end

  def invite_applicant
    @invite_applicant ||= InviteApplicant.call(
      applicant: @applicant,
      rdv_solidarites_session: rdv_solidarites_session,
      # should be sent by client
      invitation_format: department.configuration.invitation_format
    )
  end

  def department
    @applicant.department
  end
end
