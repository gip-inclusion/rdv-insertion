class InvitationsController < ApplicationController
  before_action :set_organisations, only: [:create]
  before_action :set_department, only: [:create]
  before_action :set_applicant, only: [:create, :show]
  before_action :set_invitation, only: [:show, :redirect]
  before_action :set_context_variables, only: [:show]
  skip_before_action :authenticate_agent!, only: [:invitation_code, :redirect]
  respond_to :json, only: [:index, :redirect]
  respond_to :pdf, only: [:show]

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

  def show
    authorize @invitation
    if generate_letter.success?
      render pdf: "#{@applicant&.affiliation_number}_#{@applicant&.last_name}_#{@applicant&.first_name}",
             template: "invitations/show.html.erb",
             disposition: "attachment",
             encoding: "utf-8"
    else
      render json: { success: false }
    end
  end

  def invitation_code; end

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

  def invitation_format
    params[:format] || "sms" # sms by default to keep the sms link the shortest possible
  end

  def set_invitation
    return @invitation = Invitation.find(params[:id]) if params[:token].blank?

    # TODO: identify the invitation with a uuid
    @invitation = Invitation.where(format: invitation_format, token: params[:token]).last
    raise ActiveRecord::RecordNotFound unless @invitation
  end

  def generate_letter
    @generate_letter ||= Invitations::GenerateLetter.call(invitation: @invitation)
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

  def set_context_variables
    department_level? ? set_department_variables : set_organisation_variables
  end

  def set_organisation_variables
    @organisation = Organisation.find(params[:organisation_id])
    @department = @organisation.department
  end

  def set_department_variables
    @department = Department.includes(:organisations).find(params[:department_id])
    @organisation = @invitation.organisations.first
  end
end
