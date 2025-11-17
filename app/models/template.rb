class Template < ApplicationRecord
  has_many :motif_categories, dependent: :nullify

  validates :model, :rdv_title, :rdv_title_by_phone, presence: true

  validates :rdv_purpose, :user_designation, :rdv_subject, presence: true, if: :standard?
  validates :rdv_subject, presence: true, if: :atelier?
  validates :rdv_purpose, presence: true, if: :phone_platform?

  validates :display_mandatory_warning, inclusion: [true, false]

  enum :model, { standard: "standard", atelier: "atelier", phone_platform: "phone_platform",
                 atelier_enfants_ados: "atelier_enfants_ados" }

  def mandatory_warning
    if display_mandatory_warning && phone_platform?
      "Cet appel est obligatoire pour le traitement de votre dossier"
    elsif display_mandatory_warning
      "Ce RDV est obligatoire"
    end
  end

  def name
    "#{rdv_subject} - #{rdv_title}"
  end
end
