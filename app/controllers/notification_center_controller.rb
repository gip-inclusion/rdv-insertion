class NotificationCenterController < ApplicationController
  def index
    return unless current_agent

    @total_notifications_count = creneaux_availabilities.count
    @notifications = creneaux_availabilities_as_notifications

    return unless params[:page]

    render turbo_stream: [
      turbo_stream.replace("notification_center_pagination", partial: "notification_center/pagination"),
      turbo_stream.append("notification_center_list", partial: "notification_center/list")
    ]
  end

  private

  def page
    @page ||= params[:page]&.to_i || 1
  end

  def creneaux_availabilities
    @creneaux_availabilities ||= CreneauAvailability
                                 .joins(category_configuration: :motif_category)
                                 .includes(category_configuration: :motif_category)
                                 .where(category_configuration: { organisation_id: current_organisation_id })
                                 .where(motif_category: {
                                          short_name: MOTIF_SHORT_NAMES_FOR_WHICH_NOTIFICATION_CENTER_IS_SHOWN
                                        })
                                 .with_pending_invitations
                                 .order(created_at: :desc)
  end

  def creneaux_availabilities_as_notifications
    creneaux_availabilities
      .limit(10)
      .offset((page - 1) * 10)
      .map do |creneau_availability|
      {
        id: creneau_availability.id,
        title: infer_notification_title_from_creneau_availability(creneau_availability),
        type: creneau_availability.seriousness,
        description: infer_notification_description_from_creneau_availability(creneau_availability),
        created_at: creneau_availability.created_at,
        link: notification_link,
        link_title: notification_link_title
      }
    end
  end

  def infer_notification_title_from_creneau_availability(creneau_availability)
    if creneau_availability.seriousness == "danger"
      "Il n'y a pas suffisamment de créneaux sur #{creneau_availability.category_configuration.motif_category.name}"
    elsif creneau_availability.seriousness == "warning"
      "#{creneau_availability.number_of_creneaux_available} créneaux restants " \
        "sur #{creneau_availability.category_configuration.motif_category.name}"
    elsif creneau_availability.number_of_creneaux_available >= 150
      "Plus de #{creneau_availability.number_of_creneaux_available} créneaux disponibles " \
        "sur #{creneau_availability.category_configuration.motif_category.name}"
    else
      "#{creneau_availability.number_of_creneaux_available} créneaux disponibles " \
        "sur #{creneau_availability.category_configuration.motif_category.name}"
    end
  end

  def infer_notification_description_from_creneau_availability(creneau_availability)
    message = "Il y a #{creneau_availability.number_of_pending_invitations} invitations " \
              "en attente de réponse pour #{creneau_availability.number_of_creneaux_available} " \
              "créneaux disponibles. "

    if %w[warning danger].include?(creneau_availability.seriousness)
      message += "Créez des plages d'ouverture ou augmentez le délai de prise " \
                 "de rendez-vous sur RDV-Solidarités pour ne pas bloquer les usagers."
    end

    message
  end

  def notification_link
    @notification_link ||= "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
                           "#{current_organisation.rdv_solidarites_organisation_id}/" \
                           "agent_agendas/#{current_agent.rdv_solidarites_agent_id}"
  end

  def notification_link_title
    "Voir votre agenda sur RDV-Solidarités"
  end
end
