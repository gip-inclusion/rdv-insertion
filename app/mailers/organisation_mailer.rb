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

  def creneau_unavailable(organisation:, motifs:)
    @motifs = motifs
    @organisation = organisation
    mail(
      to: organisation.email,
      subject: "[Alerte créneaux] Vérifier qu'il y a suffisamment de créneaux de libre relativement au stock d'invitations en cours",
      reply_to: "rdv-insertion@beta.gouv.fr"
    )
  end
end
