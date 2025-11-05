class AlertMotifCategoryHasChangedJob < ApplicationJob
  attr_reader :motif

  def perform(motif_id)
    @motif = Motif.find_by(id: motif_id)

    return if motif&.rdvs.blank?

    alert_on_slack
    alert_on_sentry
  end

  private

  def alert_message
    @alert_message ||=
      "⚠️ Le motif #{motif.name} (ID rdv-sp: #{motif.rdv_solidarites_motif_id}) de l'organisation" \
      " #{motif.organisation.name} (ID rdv-sp: #{motif.organisation.rdv_solidarites_organisation_id})" \
      " vient de changer de catégorie malgré la présence de #{motif.rdvs.count} rendez-vous associés."
  end

  def alert_on_slack
    SlackClient.send_to_private_channel(alert_message)
  end

  def alert_on_sentry
    Sentry.capture_message(alert_message)
  end
end
