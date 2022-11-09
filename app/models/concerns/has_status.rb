module HasStatus
  extend ActiveSupport::Concern

  included do
    enum status: { unknown: 0, waiting: 1, seen: 2, excused: 3, revoked: 4, noshow: 5 }

    const_set(:PENDING_STATUSES, %w[unknown waiting].freeze)
    const_set(:CANCELLED_STATUSES, %w[excused revoked noshow].freeze)
    const_set(:CANCELLED_BY_USER_STATUSES, %w[excused noshow].freeze)

    scope :cancelled_by_user, -> { where(status: self.class::CANCELLED_BY_USER_STATUSES) }
    scope :status, ->(status) { where(status: status) }
    scope :resolved, -> { where(status: %w[seen excused revoked noshow]) }
  end

  def pending?
    in_the_future? && status.in?(self.class::PENDING_STATUSES)
  end

  def in_the_future?
    if instance_of?(Participation)
      rdv.starts_at > Time.zone.now
    else
      starts_at > Time.zone.now
    end
  end

  def cancelled?
    status.in?(self.class::CANCELLED_STATUSES)
  end

  def resolved?
    status.in?(%w[seen excused revoked noshow])
  end

  def needs_status_update?
    !in_the_future? && status.in?(self.class::PENDING_STATUSES)
  end
end
