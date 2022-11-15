class Participation < ApplicationRecord
  self.table_name = "applicants_rdvs"

  include HasStatus

  delegate :starts_at, to: :rdv

  attribute :status, default: 0
  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  belongs_to :rdv
  belongs_to :applicant
end
