module ConvocationsHelper
  def notification_for_participation(participation, format)
    # On affiche uniquement les infos de delivrance uniquement pour les convocations créées
    participation.notifications.where(format: format, event: "participation_created").max_by(&:created_at)
  end
end
