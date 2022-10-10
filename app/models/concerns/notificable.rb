module Notificable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, dependent: :nullify
  end

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
    # we assume a convocation is a notification of a created rdv
    notifications.select(&:rdv_created?)
  end

  def sent_convocations
    convocations.select(&:sent_at?)
  end

  def convocation_formats
    sent_convocations.map(&:format)
  end

  def sent_convocations_for_category(motif_category)
    sent_convocations.select { |notification| notification.motif_category == motif_category }
  end

  def last_sent_convocation_for_category(motif_category)
    sent_convocations_for_category(motif_category).max_by(&:sent_at)
  end

  def last_convocation_for_category_sent_at(motif_category)
    last_sent_convocation_for_category(motif_category)&.sent_at
  end
end
