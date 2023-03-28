class AddSiaeMotifCategory < ActiveRecord::Migration[7.0]
  def change
    siae_template = Template.create!(
      model: "standard",
      rdv_title: "entretien d'embauche",
      rdv_title_by_phone: "entretien d'embauche téléphonique",
      rdv_purpose: "poursuivre le processus de recrutement",
      applicant_designation: "candidat.e dans une Structure d’Insertion par l’Activité Economique (SIAE)",
      rdv_subject: "candidature SIAE",
      display_mandatory_warning: false,
      display_punishable_warning: false
    )

    MotifCategory.create!(
      name: "Entretien SIAE",
      short_name: "siae_interview",
      template: siae_template,
      participation_optional: false
    )
  end
end
