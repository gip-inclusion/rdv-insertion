class Template < ApplicationRecord
  validates :model, :rdv_title, :rdv_title_by_phone, :rdv_purpose, :applicant_designation, :rdv_subject,
            presence: true

  validates :display_mandatory_warning, inclusion: [true, false]

  enum model: { standard: 0, atelier: 1, phone_platform: 2, short: 3, atelier_enfants_ados: 4 }

  def mandatory_warning
    if display_mandatory_warning && model.include?("phone_platform")
      "Cet appel est obligatoire pour le traitement de votre dossier."
    elsif display_mandatory_warning
      "Ce RDV est obligatoire."
    end
  end
end
