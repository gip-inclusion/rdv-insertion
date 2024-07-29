class OrganisationMailer < ApplicationMailer
  def user_added(to:, subject:, content:, user_attachements:, reply_to:)
    @content = content
    user_attachements.each do |attachment|
      attachments[attachment.original_filename] = attachment.read
    end
    mail(
      to: to,
      subject: subject,
      reply_to: reply_to
    )
  end

  def creneau_unavailable(organisation:, grouped_invitation_params_by_category:)
    return if organisation.email.blank?

    @organisation = organisation
    @grouped_invitation_params_by_category = grouped_invitation_params_by_category.map do |grouped_invitation_params|
      grouped_invitation_params.merge(
        referent_emails: Agent.where(rdv_solidarites_agent_id: grouped_invitation_params[:referent_ids] || [])
          .pluck(:email)
      )
    end

    mail(
      to: organisation.email,
      subject: "[Alerte créneaux] Vérifier qu'il y a suffisamment de créneaux" \
               " de libre relativement au stock d'invitations en cours",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end

  def notify_rdv_changes(to:, rdv:, participations:, event:)
    @rdv = rdv
    @participations = participations
    @event = event

    mail(
      to:,
      subject: "[Notification de RDV] Un rendez-vous a été #{I18n.t("external_notifications.events.#{event}")}",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end

  def notify_no_available_slots(organisation:, recipient:, invitation_params:)
    @organisation = organisation
    @invitation_params = invitation_params
    @referent_emails = Agent
                       .where(rdv_solidarites_agent_id: @invitation_params[:referent_ids] || [])
                       .pluck(:email)

    mail(
      to: recipient,
      subject: "[Alerte créneaux] Vérifier qu'il y a suffisamment de créneaux" \
               " de libre relativement au stock d'invitations en cours",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end
end
