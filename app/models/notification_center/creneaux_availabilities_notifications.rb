module NotificationCenter
  class CreneauxAvailabilitiesNotifications
    def initialize(agent:, organisation:, page: 1)
      @agent = agent
      @organisation = organisation
      @page = page
    end

    def notifications
      creneaux_availabilities_as_notifications
    end

    def notifications_count
      creneaux_availabilities.count
    end

    private

    def creneaux_availabilities_as_notifications
      creneaux_availabilities
        .limit(10)
        .offset((@page - 1) * 10)
        .map do |creneau_availability|
          creneau_availability.as_notification.merge(
            link: notification_link,
            link_title: notification_link_title
          )
        end
    end

    def notification_link
      @notification_link ||= "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
                             "#{@organisation.rdv_solidarites_organisation_id}/" \
                             "agent_agendas/#{@agent.rdv_solidarites_agent_id}"
    end

    def notification_link_title
      "Voir votre agenda sur RDV-Solidarités"
    end

    def creneaux_availabilities
      @creneaux_availabilities ||= CreneauAvailability
                                   .joins(category_configuration: :motif_category)
                                   .includes(category_configuration: :motif_category)
                                   .where(category_configuration: { organisation_id: @organisation.id })
                                   .where(motif_category: {
                                            short_name: NotificationCenterConcern::MOTIF_SHORT_NAMES_FOR_WHICH_NOTIFICATION_CENTER_IS_SHOWN
                                          })
                                   .with_pending_invitations
                                   .order(created_at: :desc)
    end
  end
end
