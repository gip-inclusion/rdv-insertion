class OrganisationMailer < ApplicationMailer
  def user_added(to:, subject:, content:, custom_content:, user_attachements:, reply_to:)
    @content = content
    @custom_content = custom_content

    user_attachements.each do |attachment|
      attachments[attachment.original_filename] = attachment.read
    end

    mail(
      to: to,
      subject: subject,
      reply_to: reply_to
    )
  end

  def creneau_unavailable(organisation:, invitations_without_creneaux_by_motif_category:)
    @organisation = organisation
    @invitations_without_creneaux_by_motif_category = invitations_without_creneaux_by_motif_category

    return if @organisation.email.blank?

    mail(
      to: @organisation.email,
      subject: "[Alerte créneaux] Vérifier qu'il y a suffisamment de créneaux" \
               " de libre relativement au stock d'invitations en cours",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end

  def notify_rdv_changes(to:, rdv:, participations:, event:)
    @rdv = rdv
    @participations = participations
    @event = event
    @motif_category = @participations.first.motif_category

    mail(
      to:,
      subject: "[Notification de RDV] Un rendez-vous a été #{I18n.t("external_notifications.events.#{event}")}",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end

  def notify_no_available_slots(organisation:, invitations:, motif_category_name:, recipient:)
    @organisation = organisation
    @invitations = invitations
    @motif_category_name = motif_category_name
    @post_codes = invitations.map(&:user_post_code).compact.uniq
    @referent_emails = invitations.flat_map(&:referent_emails).compact.uniq

    mail(
      to: recipient,
      subject: "[Alerte créneaux] Vérifier qu'il y a suffisamment de créneaux" \
               " de libre relativement au stock d'invitations en cours",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end
end
