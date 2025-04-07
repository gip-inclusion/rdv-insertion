module NotificationCenterConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_notifications, if: -> { request.get? }
  end

  private

  def set_notifications
    return unless current_agent

    @notifications = CreneauAvailability
                     .where(category_configuration: current_agent.category_configurations)
                     .order(created_at: :desc)
                     .includes(category_configuration: [:motif_category, :invitations])
                     .joins(category_configuration: :invitations)
                     .where("invitations.expires_at > ? OR invitations.expires_at IS NULL", Time.zone.now)
                     .limit(10)
                     .map do |creneau_availability|
      {
        id: creneau_availability.id,
        title: infer_notification_title_from_creneau_availability(creneau_availability),
        type: infer_notification_type_from_creneau_availability(creneau_availability),
        description: infer_notification_description_from_creneau_availability(creneau_availability),
        created_at: creneau_availability.created_at
      }
    end
  end

  def infer_notification_title_from_creneau_availability(creneau_availability)
    if creneau_availability.number_of_creneaux_available.zero?
      "Il n’y a plus de créneaux sur #{creneau_availability.category_configuration.motif_category.name}"
    elsif creneau_availability.number_of_creneaux_available < 25
      "#{creneau_availability.number_of_creneaux_available} créneaux restants " \
        "sur #{creneau_availability.category_configuration.motif_category.name}"
    elsif creneau_availability.number_of_creneaux_available >= 200
      "Plus de #{creneau_availability.number_of_creneaux_available} créneaux disponibles " \
        "sur #{creneau_availability.category_configuration.motif_category.name}"
    else
      "#{creneau_availability.number_of_creneaux_available} créneaux disponibles " \
        "sur #{creneau_availability.category_configuration.motif_category.name}"
    end
  end

  def infer_notification_description_from_creneau_availability(creneau_availability)
    message = "Il y a #{creneau_availability.category_configuration.invitations.count} invitations " \
        "en attente de réponse. "


    if creneau_availability.number_of_creneaux_available < 25
      message += "Créez des plages d'ouverture ou augmentez le délai de prise " \
        "de rendez-vous sur RDV-Soldiarités pour le pas bloquer les usagers."
    end

    message
  end

  def infer_notification_type_from_creneau_availability(creneau_availability)
    if creneau_availability.number_of_creneaux_available > 30
      "info"
    elsif creneau_availability.number_of_creneaux_available > 10
      "warning"
    else
      "danger"
    end
  end
end
