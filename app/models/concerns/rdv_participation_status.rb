module RdvParticipationStatus
  extend ActiveSupport::Concern

  PENDING_STATUSES = %w[unknown].freeze
  CANCELLED_STATUSES = %w[excused revoked noshow].freeze
  CANCELLED_BY_USER_STATUSES = %w[excused noshow].freeze

  included do
    enum :status, { unknown: "unknown", seen: "seen", excused: "excused", revoked: "revoked", noshow: "noshow" }

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

  def possible_new_statuses
    possible_statuses = in_the_future? ? %w[unknown revoked excused] : %w[seen revoked excused noshow]
    possible_statuses - [status]
  end

  def needs_status_update?
    in_the_past? && status.in?(PENDING_STATUSES)
  end

  def human_status
    status == "unknown" ? human_unknown_status : I18n.t("activerecord.attributes.rdv.statuses.#{status}")
  end

  private

  def human_unknown_status
    I18n.t("activerecord.attributes.rdv.unknown_statuses.#{in_the_future? ? 'pending' : 'needs_status_update'}")
  end
end
