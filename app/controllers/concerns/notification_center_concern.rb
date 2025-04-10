module NotificationCenterConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_has_notifications, if: -> { request.get? && !turbo_frame_request? && !request.xhr? }
    helper_method :most_recent_notification_read, :oldest_notification_read, :notification_read?
  end

  private

  def set_has_notifications
    return unless current_agent

    @has_unread_important_notifications = CreneauAvailability
                                          .where(category_configuration: current_agent.category_configurations)
                                          .where(created_at: most_recent_notification_read...)
                                          .order(created_at: :desc)
                                          .first&.serious?
  end

  def most_recent_notification_read
    Time.zone.at(cookies["most_recent_notification_read"].to_i)
  end

  def oldest_notification_read
    Time.zone.at(cookies["oldest_notification_read"]&.to_i || Time.zone.now.strftime("%s%L").to_i)
  end

  def notification_read?(notification)
    notification[:created_at].to_i <= most_recent_notification_read.to_i &&
      notification[:created_at].to_i >= oldest_notification_read.to_i
  end
end
