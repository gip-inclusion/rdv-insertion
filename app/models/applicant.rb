class Applicant < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = (
    RdvSolidarites::User::RECORD_ATTRIBUTES - [:id, :phone_number, :birth_name, :created_at, :invited_at]
  )

  include SearchableConcern
  include HasStatusConcern

  belongs_to :department
  has_many :invitations, dependent: :nullify
  has_and_belongs_to_many :rdvs

  validates :uid, presence: true, uniqueness: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true
  validates :last_name, :first_name, :title, presence: true

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }
  enum status: {
    not_invited: 0, invitation_pending: 1, rdv_creation_pending: 2, rdv_pending: 3,
    rdv_needs_status_update: 4, rdv_noshow: 5, rdv_revoked: 6, rdv_excused: 7,
    rdv_seen: 8
  }

  delegate :rdv_solidarites_organisation_id, to: :department

  def last_sent_invitation
    invitations.select(&:sent_at).max_by(&:sent_at)
  end

  def last_invitation_sent_at
    last_sent_invitation&.sent_at
  end

  def full_name
    "#{title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def as_json(_opts = {})
    super.merge(
      created_at: created_at&.to_date&.strftime("%d/%m/%Y"),
      invitation_sent_at: last_invitation_sent_at&.to_date&.strftime("%d/%m/%Y")
    )
  end
end
