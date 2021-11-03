class InvitationsController < ApplicationController
  before_action :set_department, only: [:create]
  before_action :set_applicant, only: [:create]
  before_action :set_invitation, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:redirect]
  respond_to :json

  def create
    authorize @department, :invite_applicant?
    if invite_applicant.success?
      render json: { success: true, invitation: invite_applicant.invitation }
    else
      render json: { success: false, errors: invite_applicant.errors }
    end
  end

  def redirect
    @invitation.clicked = true
    @invitation.save
    redirect_to @invitation.link
  end

  private

  def set_applicant
    @applicant = @department.applicants.includes(:invitations).find(params[:applicant_id])
  end

  def set_invitation
    @invitation = Invitation.find_by!(format: invitation_format, token: params[:token])
  end

  def invite_applicant
    @invite_applicant ||= Invitations::InviteApplicant.call(
      applicant: @applicant,
      department: @department,
      rdv_solidarites_session: rdv_solidarites_session,
      invitation_format: params[:format]
    )
  end

  def set_department
    @department = Department.find(params[:department_id])
  end

  def invitation_format
    params[:format] || "sms" # sms by default to keep the sms link the shortest possible
  end
end
