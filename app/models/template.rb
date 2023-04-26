class Template < ApplicationRecord
  MANDATORY_WARNING = "Ce RDV est obligatoire.".freeze
  MANDATORY_PHONE_CALL_WARNING = "Cet appel est obligatoire pour le traitement de votre dossier.".freeze

  has_many :motif_categories, dependent: :nullify

  validates :model, presence: true

  validates :rdv_title, :rdv_title_by_phone, :rdv_purpose, :applicant_designation, :rdv_subject,
            presence: true, if: :standard?
  validates :display_mandatory_warning, inclusion: [true, false]

  enum model: { standard: 0, atelier: 1, phone_platform: 2, short: 3, atelier_enfants_ados: 4 }

  def mandatory_warning
    if display_mandatory_warning && model.include?("phone_platform")
      MANDATORY_PHONE_CALL_WARNING
    elsif display_mandatory_warning
      MANDATORY_WARNING
    end
  end
end
