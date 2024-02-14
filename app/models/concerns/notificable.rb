module Notificable
  extend ActiveSupport::Concern

  def notified?
    notifications.any?
  end

  def last_sent_notification
    notifications.max_by(&:created_at)
  end

  def last_notification_sent_at
    last_sent_notification&.created_at
  end

  def convocations
    # we assume a convocation is a notification of a created participation
    # since we only send notifications for convocation motifs for now
    notifications.select(&:participation_created?)
  end

  def sent_sms_convocations
    convocations.select(&:format_sms?)
  end

  def sent_email_convocations
    convocations.select(&:format_email?)
  end

  def last_sent_convocation
    convocations.max_by(&:created_at)
  end

  def last_convocation_sent_at
    last_sent_convocation&.created_at
  end
end
