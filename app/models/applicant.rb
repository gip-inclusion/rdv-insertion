class Applicant < ApplicationRecord
  belongs_to :department
  has_many :invitations, dependent: :nullify

  validates :uid, presence: true, uniqueness: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true
  validates :last_name, :first_name, :title, presence: true

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }

  delegate :rdv_solidarites_organisation_id, to: :department

  def invitation_sent_at
    invitations.last&.sent_at
  end

  def full_name
    "#{title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def as_json(_opts = {})
    {
      uid: uid,
      id: id,
      invitation_sent_at: invitation_sent_at&.to_date&.strftime("%m/%d/%Y")
    }
  end
end
