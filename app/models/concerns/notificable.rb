module Notificable
  extend ActiveSupport::Concern

  def notified?
    notifications.any?(&:sent_at?)
  end

  def sent_notifications
    notifications.select(&:sent_at?)
  end

  def last_sent_notification
    sent_notifications.max_by(&:sent_at)
  end

  def last_notification_sent_at
    last_sent_notification&.sent_at
  end

  def convocations
    # we assume a convocation is a notification of a created participation
    notifications.select(&:participation_created?)
  end

  def sent_convocations
    convocations.select(&:sent_at?)
  end

  def sent_sms_convocations
    sent_convocations.select(&:format_sms?)
  end

  def sent_email_convocations
    sent_convocations.select(&:format_email?)
  end

  def last_sent_convocation
    sent_convocations.max_by(&:sent_at)
  end

  def last_sent_convocation_sent_at
    last_sent_convocation&.sent_at
  end
end
