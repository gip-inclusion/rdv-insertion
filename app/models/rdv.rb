class Rdv < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :address, :cancelled_at, :context, :created_by, :duration_in_min, :starts_at, :status,
    :uuid, :rdv_solidarites_motif_id, :rdv_solidarites_lieu_id
  ].freeze
  PENDING_STATUSES = %w[unknown waiting].freeze
  CANCELLED_STATUSES = %w[excused revoked noshow].freeze
  CANCELLED_BY_USER_STATUSES = %w[excused noshow].freeze

  after_commit :refresh_applicant_statuses, on: [:create, :update]

  belongs_to :organisation
  has_and_belongs_to_many :applicants

  validates :applicants, :rdv_solidarites_motif_id, :starts_at, :duration_in_min, presence: true
  validates :rdv_solidarites_rdv_id, uniqueness: true, presence: true

  enum created_by: { agent: 0, user: 1, file_attente: 2 }, _prefix: :created_by
  enum status: { unknown: 0, waiting: 1, seen: 2, excused: 3, revoked: 4, noshow: 5 }

  scope :cancelled_by_user, -> { where(status: CANCELLED_BY_USER_STATUSES) }
  scope :status, ->(status) { where(status: status) }
  scope :resolved, -> { where(status: %w[seen excused revoked noshow]) }

  def pending?
    in_the_future? && status.in?(PENDING_STATUSES)
  end

  def in_the_future?
    starts_at > Time.zone.now
  end

  def cancelled?
    status.in?(CANCELLED_STATUSES)
  end

  def delay_in_days
    starts_at.to_datetime.mjd - created_at.to_datetime.mjd
  end

  private

  def refresh_applicant_statuses
    RefreshApplicantStatusesJob.perform_async(applicant_ids)
  end
end
