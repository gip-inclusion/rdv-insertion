class Template < ApplicationRecord
  MANDATORY_WARNING = "Ce RDV est obligatoire.".freeze
  MANDATORY_PHONE_CALL_WARNING = "Cet appel est obligatoire pour le traitement de votre dossier.".freeze

  has_many :motif_categories, dependent: :nullify

  validates :model, presence: true

  validates :rdv_title, :rdv_title_by_phone, :rdv_purpose, :applicant_designation, :rdv_subject,
            presence: true, if: :standard?
  validates :display_mandatory_warning, inclusion: [true, false]
  validates :punishable_warning, :documents_warning, presence: true, allow_blank: true

  enum model: { standard: 0, atelier: 1, phone_platform: 2, short: 3, atelier_enfants_ados: 4 }
end
