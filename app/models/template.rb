class Template < ApplicationRecord
  has_many :motif_categories, dependent: :nullify

  validates :model, presence: true

  validates :rdv_title, :rdv_title_by_phone, :rdv_purpose, :applicant_designation, :rdv_subject,
            presence: true, if: :standard?
  validates :display_mandatory_warning, :display_punishable_warning, inclusion: [true, false], if: :standard?

  enum model: { standard: 0, atelier: 1, phone_platform: 2 }
end
