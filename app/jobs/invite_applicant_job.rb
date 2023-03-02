class InviteApplicantJob < ApplicationJob
  sidekiq_options retry: 10

  def perform(
    applicant_id, organisation_id, invitation_attributes, motif_category_id, rdv_solidarites_session_credentials
  )
    @applicant = Applicant.find(applicant_id)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @invitation_attributes = invitation_attributes.deep_symbolize_keys
    @motif_category = MotifCategory.find(motif_category_id)
    @rdv_solidarites_session_credentials = rdv_solidarites_session_credentials.deep_symbolize_keys

    Invitation.with_advisory_lock "invite_applicant_job_#{@applicant.id}" do
      invite_applicant
    end
  end

  private

  def invite_applicant
    return if invitation_already_sent_today?

    @invitation = Invitation.new(
      applicant: @applicant,
      department: @department,
      organisations: [@organisation],
      number_of_days_to_accept_invitation: matching_configuration.number_of_days_to_accept_invitation,
      rdv_context: rdv_context,
      valid_until: matching_configuration.number_of_days_before_action_required.days.from_now,
      rdv_with_referents: matching_configuration.rdv_with_referents,
      **@invitation_attributes
    )

    return if save_and_send_invitation.success?

    raise(
      FailedServiceError,
      "Could not send invitation to applicant #{@applicant.id} in InviteApplicantJob: " \
      "#{save_and_send_invitation.errors}"
    )
  end

  def invitation_format
    @invitation_attributes[:format]
  end

  def rdv_context
    RdvContext.with_advisory_lock "setting_rdv_context_for_applicant_#{@applicant.id}" do
      RdvContext.find_or_create_by!(motif_category: @motif_category, applicant: @applicant)
    end
  end

  def matching_configuration
    @matching_configuration ||= @organisation.configurations.find_by!(motif_category: @motif_category)
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(
      invitation: @invitation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def invitation_already_sent_today?
    rdv_context.invitations.where(format: invitation_format).where("sent_at > ?", 24.hours.ago).present?
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSession.new(**@rdv_solidarites_session_credentials)
  end
end
