module RdvParticipationStatus
  extend ActiveSupport::Concern

  # unknow status is replaced by pending for future rdvs and needs_status_update for past rdvs in the app
  # we let it here for more clarity ; it is still the value stored in the database
  PENDING_STATUSES = %w[unknown].freeze
  CANCELLED_STATUSES = %w[excused revoked noshow].freeze
  CANCELLED_BY_USER_STATUSES = %w[excused noshow].freeze

  included do
    enum status: { unknown: 0, seen: 2, excused: 3, revoked: 4, noshow: 5 }

    scope :cancelled_by_user, -> { where(status: CANCELLED_BY_USER_STATUSES) }
    scope :not_cancelled, -> { where.not(status: CANCELLED_STATUSES) }
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
    in_the_future? ? %w[pending revoked excused] : %w[seen revoked excused noshow]
  end

  def needs_status_update?
    in_the_past? && status.in?(PENDING_STATUSES)
  end

  def human_status
    self[:status] == "unknown" ? human_unknown_status : self[:status]
  end

  def human_unknown_status
    in_the_future? ? "pending" : "needs_status_update"
  end
end
