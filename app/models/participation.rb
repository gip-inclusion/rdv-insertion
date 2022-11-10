class Participation < ApplicationRecord
  self.table_name = "applicants_rdvs"

  include HasStatus

  validates :status, presence: true
  validates :rdv_solidarites_participation_id, uniqueness: true, allow_nil: true

  belongs_to :rdv
  belongs_to :applicant

  before_validation :set_status_from_rdv, on: :create

  def set_status_from_rdv
    return if rdv&.status.nil?

    self.status = rdv.status
  end
end
