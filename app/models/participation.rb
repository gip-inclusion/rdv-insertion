class Participation < ApplicationRecord
  self.table_name = "applicants_rdvs"

  include HasStatus

  validates :status, presence: true

  belongs_to :rdv
  belongs_to :applicant
end
