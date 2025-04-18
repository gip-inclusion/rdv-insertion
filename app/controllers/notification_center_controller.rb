class NotificationCenterController < ApplicationController
  after_action :update_notification_read_timestamps, only: [:index]

  def index
    @notification_center = NotificationCenter::CreneauxAvailabilitiesNotifications.new(
      agent: current_agent,
      organisation: current_organisation,
      page: page
    )

    @total_notifications_count = @notification_center.notifications_count
    @notifications = @notification_center.notifications

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
