FactoryBot.define do
  factory :template do
    model { "standard" }
    rdv_title { "rendez-vous d'orientation" }
    rdv_title_by_phone { "rendez-vous d'orientation téléphonique" }
    rdv_purpose { "démarrer un parcours d'accompagnement" }
    applicant_designation { "bénéficiaire du RSA" }
    rdv_subject { "RSA" }
    display_mandatory_warning { true }
    display_punishable_warning { false }
  end
end
