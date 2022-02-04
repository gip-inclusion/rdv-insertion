class InvitationsController < ApplicationController
  before_action :set_organisations, only: [:create]
  before_action :set_department, only: [:create]
  before_action :set_applicant, only: [:create]
  before_action :set_invitation, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:index, :redirect]
  respond_to :json

  def create
    @invitation = Invitation.new(
      applicant: @applicant, department: @department, organisations: @organisations, **invitation_params
    )
    authorize @invitation
    if save_and_send_invitation.success?
      render json: { success: true, invitation: @invitation }
    else
      render json: { success: false, errors: save_and_send_invitation.errors }
    end
  end

  def index; end

  def redirect
    @invitation.clicked = true
    @invitation.save
    redirect_to @invitation.link
  end

  private

  def invitation_params
    params.require(:invitation).permit(:format, :context, :help_phone_number, :rdv_solidarites_lieu_id)
  end

  def set_applicant
    @applicant = policy_scope(Applicant).includes(:invitations).find(params[:applicant_id])
  end

  def set_invitation
    # TODO: identify the invitation with a uuid
    @invitation = Invitation.where(format: invitation_format, token: params[:token]).last
    raise ActiveRecord::RecordNotFound unless @invitation
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(
      invitation: @invitation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_department
    @department = @organisations.first.department
  end

  def set_organisations
    @organisations = \
      if department_level?
        policy_scope(Organisation).where(department_id: params[:department_id])
      else
        policy_scope(Organisation).where(id: params[:organisation_id])
      end
  end

  def invitation_format
    params[:format] || "sms" # sms by default to keep the sms link the shortest possible
  end
end
