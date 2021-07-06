class Applicant < ApplicationRecord
  belongs_to :department
  has_many :invitations, dependent: :nullify

  validates :uid, presence: true, uniqueness: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true

  enum role: { demandeur: 0, conjoint: 1 }

  delegate :rdv_solidarites_organisation_id, to: :department

  def invitation_sent_at
    invitations.last&.sent_at
  end

  def as_json(_opts = {})
    {
      uid: uid,
      id: id,
      invitation_sent_at: invitation_sent_at&.to_date&.strftime("%m/%d/%Y")
    }
  end
end
