class InviteApplicantJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(applicant_id, organisation_id, session_credentials, invitation_attributes)
    @applicant = Applicant.find(applicant_id)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @attributes = invitation_attributes.deep_symbolize_keys
    @session_credentials = session_credentials.deep_symbolize_keys

    Invitation.with_advisory_lock "invite_job_for_applicant_#{@applicant.id}_with_#{invitation_format}" do
      invite_applicant
    end
  end

  private

  def invite_applicant
    return if invitation_already_sent_today?

    @invitation = Invitation.new(
      applicant: @applicant, department: @department, organisations: [@organisation], **@attributes
    )
    capture_exception if save_and_send_invitation.failure?
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(
      invitation: @invitation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def invitation_format
    @attributes[:format]
  end

  def capture_exception
    Sentry.capture_exception(
      FailedServiceError.new("save and send invitation error"),
      extra: {
        applicant: @applicant,
        service_errors: save_and_send_invitation.errors,
        organisation: @organisation,
        invitation_attributes: @invitation_attributes
      }
    )
  end

  def invitation_already_sent_today?
    @applicant.invitations.where(format: invitation_format).where("sent_at > ?", 24.hours.ago).present?
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSession.new(**@session_credentials)
  end
end
