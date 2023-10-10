module RdvParticipationStatus
  extend ActiveSupport::Concern

  PENDING_STATUSES = %w[unknown].freeze
  CANCELLED_STATUSES = %w[excused revoked noshow].freeze
  CANCELLED_BY_USER_STATUSES = %w[excused noshow].freeze

  included do
    enum status: { unknown: 0, seen: 2, excused: 3, revoked: 4, noshow: 5 }

    scope :cancelled_by_user, -> { where(status: CANCELLED_BY_USER_STATUSES) }
    scope :status, ->(status) { where(status: status) }
    scope :resolved, -> { where(status: %w[seen excused revoked noshow]) }
  end

  def pending?
    in_the_future? && status.in?(PENDING_STATUSES)
  end

  def in_the_future?
    starts_at > Time.zone.now
  end

  def in_the_past?
    starts_at < Time.zone.now
  end

  def cancelled?
    status.in?(CANCELLED_STATUSES)
  end

  def cancelled_by_user?
    status.in?(CANCELLED_BY_USER_STATUSES)
  end

  def resolved?
    status.in?(%w[seen excused revoked noshow])
  end

  def available_statuses
    available_list = in_the_future? ? %w[unknown revoked excused] : %w[seen revoked excused noshow]
    self.class.statuses.slice(*available_list)
  end

  def needs_status_update?
    !in_the_future? && status.in?(PENDING_STATUSES)
  end
end
