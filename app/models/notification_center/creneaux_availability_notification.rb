module NotificationCenter
  class CreneauxAvailabilityNotification
    attr_reader :creneau_availability

    delegate :id, :created_at, :availability_level, :number_of_creneaux_available, :category_configuration,
             to: :creneau_availability

    def initialize(creneau_availability)
      @creneau_availability = creneau_availability
    end

    def title
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

    def type
      creneau_availability.availability_level
    end

    def description
      message = "Il y a #{creneau_availability.number_of_pending_invitations} invitations " \
                "en attente de réponse pour #{creneau_availability.number_of_creneaux_available} " \
                "créneaux disponibles. "

      if %w[warning danger].include?(creneau_availability.availability_level)
        message += "Créez des plages d'ouverture ou augmentez le délai de prise " \
                   "de rendez-vous sur RDV-Solidarités pour ne pas bloquer les usagers."
      end

      message
    end
  end
end
