module ConvocationsHelper
  def notification_for_participation(participation, format)
    # On affiche les infos de delivrance des convocations pour les rdv créés uniquement
    participation.notifications.where(format: format, event: "participation_created").max_by(&:created_at)
  end
end
