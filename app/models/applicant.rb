class Applicant < ApplicationRecord
  RDV_SOLIDARITES_USER_SHARED_ATTRIBUTES = [
    :first_name, :last_name, :birth_date, :address, :email, :phone_number_formatted
  ].freeze

  include SearchableConcern

  belongs_to :department
  has_many :invitations, dependent: :nullify

  validates :uid, presence: true, uniqueness: true
  validates :rdv_solidarites_user_id, uniqueness: true, allow_nil: true
  validates :last_name, :first_name, :title, presence: true

  enum role: { demandeur: 0, conjoint: 1 }
  enum title: { monsieur: 0, madame: 1 }

  delegate :rdv_solidarites_organisation_id, to: :department

  def first_sent_invitation
    invitations.find { _1.sent_at.present? }
  end

  def first_invitation_sent_at
    first_sent_invitation&.sent_at
  end

  def full_name
    "#{title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def as_json(_opts = {})
    super.merge(
      created_at: created_at&.to_date&.strftime("%d/%m/%Y"),
      invitation_sent_at: first_sent_invitation&.to_date&.strftime("%d/%m/%Y")
    )
  end
end
