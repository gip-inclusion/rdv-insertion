class NotificationCenterController < ApplicationController
  after_action :update_notification_read_timestamps, only: [:index]

  def index
    @total_notifications_count = creneaux_availabilities.count
    @notifications = creneaux_availabilities_as_notifications

    # When paginating we only re-render the list and the pagination
    # Not the entire notification center
    if loading_more_notifications?
      render turbo_stream: [
        turbo_stream.replace("notification_center_pagination", partial: "notification_center/pagination"),
        turbo_stream.append("notification_center_list", partial: "notification_center/list")
      ]
    else
      # Render the entire notification center
      render "index"
    end
  end

  private

  def page
    @page ||= params[:page]&.to_i || 1
  end

  def loading_more_notifications?
    params[:page].present?
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
        type: creneau_availability.availability_level,
        description: infer_notification_description_from_creneau_availability(creneau_availability),
        created_at: creneau_availability.created_at,
        link: notification_link,
        link_title: notification_link_title
      }
    end
  end

  def infer_notification_title_from_creneau_availability(creneau_availability)
    if creneau_availability.availability_level == "danger"
      "Il n'y a pas suffisamment de créneaux sur #{creneau_availability.category_configuration.motif_category.name}"
    elsif creneau_availability.availability_level == "warning"
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

    if %w[warning danger].include?(creneau_availability.availability_level)
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

  def update_notification_read_timestamps
    return if @notifications.empty?

    update_most_recent_notification_read_timestamp if agent_hasnt_read_most_recent_notification?
    update_oldest_notification_read_timestamp if agent_hasnt_read_oldest_notification?
  end

  def update_most_recent_notification_read_timestamp
    cookies["most_recent_notification_read_on_#{current_organisation_id}"] = first_notification_created_at + 1
  end

  def update_oldest_notification_read_timestamp
    cookies["oldest_notification_read_on_#{current_organisation_id}"] = last_notification_created_at - 1
  end

  def agent_hasnt_read_most_recent_notification?
    most_recent_notification_read.to_i.zero? || first_notification_created_at > most_recent_notification_read.to_i
  end

  def agent_hasnt_read_oldest_notification?
    oldest_notification_read.to_i.zero? || last_notification_created_at < oldest_notification_read.to_i
  end

  def first_notification_created_at
    @notifications.first[:created_at].to_i
  end

  def last_notification_created_at
    @notifications.last[:created_at].to_i
  end
end
