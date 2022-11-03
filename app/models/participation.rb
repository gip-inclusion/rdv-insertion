class Participation < ApplicationRecord
  self.table_name = "applicants_rdvs"

  PENDING_STATUSES = %w[unknown waiting].freeze
  CANCELLED_STATUSES = %w[excused revoked noshow].freeze
  CANCELLED_BY_USER_STATUSES = %w[excused noshow].freeze

  belongs_to :rdv
  belongs_to :applicant

  validates :status, presence: true

  enum status: { unknown: 0, waiting: 1, seen: 2, excused: 3, revoked: 4, noshow: 5 }

  scope :cancelled_by_user, -> { where(status: CANCELLED_BY_USER_STATUSES) }
  scope :status, ->(status) { where(status: status) }
  scope :resolved, -> { where(status: %w[seen excused revoked noshow]) }

  def pending?
    in_the_future? && status.in?(PENDING_STATUSES)
  end

  def in_the_future?
    rdv.starts_at > Time.zone.now
  end

  def cancelled?
    status.in?(CANCELLED_STATUSES)
  end

  def resolved?
    status.in?(%w[seen excused revoked noshow])
  end
end
