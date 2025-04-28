class NotificationCenterController < ApplicationController
  after_action :update_notification_read_timestamps, only: [:index]
  before_action :set_notification_link, :set_notification_link_title, only: :index

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
      NotificationCenter::CreneauxAvailabilityNotification.new(creneau_availability)
    end
  end

  def set_notification_link
    @notification_link = "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
                         "#{current_organisation.rdv_solidarites_organisation_id}/" \
                         "agent_agendas/#{current_agent.rdv_solidarites_agent_id}"
  end

  def set_notification_link_title
    @notification_link_title = "Voir votre agenda sur RDV-Solidarités"
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
    @notifications.first.created_at.to_i
  end

  def last_notification_created_at
    @notifications.last.created_at.to_i
  end
end
