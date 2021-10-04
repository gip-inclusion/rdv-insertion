class InvitationsController < ApplicationController
  before_action :set_applicant, only: [:create]
  before_action :set_invitation, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:redirect]
  respond_to :json

  def create
    authorize @applicant, :invite?
    if invite_applicant.success?
      render json: { success: true, invitations: invite_applicant.invitations }
    else
      render json: { success: false, errors: invite_applicant.errors }
    end
  end

  def redirect
    @invitation.seen = true
    @invitation.save
    redirect_to @invitation.link
  end

  private

  def set_applicant
    @applicant = Applicant.find(params[:applicant_id])
  end

  def invite_applicant
    @invite_applicant ||= Invitations::InviteApplicant.call(
      applicant: @applicant,
      rdv_solidarites_session: rdv_solidarites_session,
      # TODO: should be sent by client
      invitation_format: department.configuration.invitation_format
    )
  end

  def department
    @applicant.department
  end

  def set_invitation
    @invitation = Invitation.find_by!(token: params[:token])
  end
end
