class Participation < ApplicationRecord
  include HasStatus

  delegate :starts_at, to: :rdv

  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  belongs_to :rdv
  belongs_to :applicant
  after_commit :refresh_applicant_context_statuses, on: [:destroy]

  private

  def refresh_applicant_context_statuses
    RefreshRdvContextStatusesJob.perform_async(applicant.rdv_context_ids)
  end
end
