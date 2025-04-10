module NotificationCenterConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_has_notifications, if: :show_notification_center?
    helper_method :most_recent_notification_read, :oldest_notification_read, :notification_read?, :show_notification_center?
  end

  private

  def set_has_notifications
    @has_unread_important_notifications = CreneauAvailability
                                          .joins(:category_configuration)
                                          .where(category_configuration: { organisation_id: current_organisation_id })
                                          .where(created_at: most_recent_notification_read...)
                                          .with_pending_invitations
                                          .order(created_at: :desc)
                                          .first&.serious?
  end

  def most_recent_notification_read
    Time.zone.at(cookies["most_recent_notification_read_on_#{current_organisation_id}"].to_i)
  end

  def oldest_notification_read
    Time.zone.at(cookies["oldest_notification_read_on_#{current_organisation_id}"]&.to_i || Time.zone.now.strftime("%s%L").to_i)
  end

  def notification_read?(notification)
    notification[:created_at].to_i <= most_recent_notification_read.to_i &&
      notification[:created_at].to_i >= oldest_notification_read.to_i
  end

  def show_notification_center?
    return false if !request.get? || turbo_frame_request? || request.xhr?
    return false unless current_agent

    params[:organisation_id].present?
  end
end
