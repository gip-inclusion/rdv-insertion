class NotificationCenterController < ApplicationController
  after_action :update_notification_read_at_timestamp, only: [:index]
  before_action :set_notification_link, :set_notification_link_title, only: :index

  def index
    @total_notifications_count = creneaux_availabilities.total_count
    @notifications = creneaux_availabilities.map do |creneau_availability|
      NotificationCenter::CreneauxAvailabilityNotification.new(creneau_availability)
    end

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

  def loading_more_notifications?
    params[:page].present?
  end

  def creneaux_availabilities
    @creneaux_availabilities ||= CreneauAvailability
                                 .joins(:category_configuration)
                                 .preload(category_configuration: :motif_category)
                                 .where(category_configuration: { organisation_id: current_organisation_id })
                                 .where(category_configuration: { rdv_with_referents: false })
                                 .with_rsa_related_motif
                                 .with_pending_invitations
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(10)
  end

  def set_notification_link
    @notification_link = "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
                         "#{current_organisation.rdv_solidarites_organisation_id}/" \
                         "agent_agendas/#{current_agent.rdv_solidarites_agent_id}"
  end

  def set_notification_link_title
    @notification_link_title = "Voir votre agenda sur RDV-Solidarités"
  end

  def update_notification_read_at_timestamp
    cookies["notifications_read_at_on_org_id_#{current_organisation_id}"] = Time.now.to_i
  end
end
