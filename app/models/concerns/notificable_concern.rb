module NotificableConcern
  extend ActiveSupport::Concern

  included do
    has_many :notifications, dependent: :destroy
  end

  def notified?
    notifications.any?(&:sent_at)
  end

  def last_sent_notification
    notifications.select(&:sent_at).max_by(&:sent_at)
  end

  def last_notification_sent_at
    last_sent_notification&.sent_at
  end
end
