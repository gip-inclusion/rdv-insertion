class Applicant < ApplicationRecord
  belongs_to :department
  validates :uid, presence: true, uniqueness: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true

  enum role: { demandeur: 0, conjoint: 1 }
end
