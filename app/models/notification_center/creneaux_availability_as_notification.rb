module NotificationCenter
  module CreneauxAvailabilityAsNotification
    extend ActiveSupport::Concern

    def as_notification
      {
        id: id,
        title: notification_title,
        type: availability_level,
        description: notification_description,
        created_at: created_at
      }
    end

    private

    def notification_title
      if availability_level == "danger"
        "Il n'y a pas suffisamment de créneaux sur #{category_configuration.motif_category.name}"
      elsif availability_level == "warning"
        "#{number_of_creneaux_available} créneaux restants " \
          "sur #{category_configuration.motif_category.name}"
      elsif number_of_creneaux_available >= 150
        "Plus de #{number_of_creneaux_available} créneaux disponibles " \
          "sur #{category_configuration.motif_category.name}"
      else
        "#{number_of_creneaux_available} créneaux disponibles " \
          "sur #{category_configuration.motif_category.name}"
      end
    end

    def notification_description
      message = "Il y a #{number_of_pending_invitations} invitations " \
                "en attente de réponse pour #{number_of_creneaux_available} " \
                "créneaux disponibles. "

      if %w[warning danger].include?(availability_level)
        message += "Créez des plages d'ouverture ou augmentez le délai de prise " \
                   "de rendez-vous sur RDV-Solidarités pour ne pas bloquer les usagers."
      end

      message
    end
  end
end
