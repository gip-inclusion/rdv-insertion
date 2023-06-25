class AddMotifCategoriesAndTemplatesForSiae < ActiveRecord::Migration[7.0]
  def up
    siae_follow_up_template = Template.create!(
      model: "standard",
      rdv_title: "rendez-vous de suivi",
      rdv_title_by_phone: "rendez-vous de suivi téléphonique",
      rdv_purpose: "faire un point avec votre référent",
      applicant_designation: "salarié.e au sein de notre structure",
      rdv_subject: "suivi SIAE",
      display_mandatory_warning: false,
      punishable_warning: ""
    )

    siae_collective_information_template = Template.create!(
      model: "standard",
      rdv_title: "rendez-vous collectif d'information",
      rdv_title_by_phone: "rendez-vous collectif d'information téléphonique",
      rdv_purpose: "découvrir cette structure",
      applicant_designation: "candidat.e dans une Structure d’Insertion par l’Activité Economique (SIAE)",
      rdv_subject: "candidature SIAE",
      display_mandatory_warning: false,
      punishable_warning: ""
    )

    MotifCategory.create!(
      name: "Suivi SIAE",
      short_name: "siae_follow_up",
      template: siae_follow_up_template,
      participation_optional: false
    )

    MotifCategory.create!(
      name: "Info coll. SIAE",
      short_name: "siae_collective_information",
      template: siae_collective_information_template,
      participation_optional: false
    )
  end

  def down
    MotifCategory.find_by(short_name: "siae_follow_up").destroy!
    MotifCategory.find_by(short_name: "siae_collective_information").destroy!
    Template.find_by(rdv_subject: "suivi SIAE", model: "standard").destroy!
    Template.find_by(
      rdv_subject: "candidature SIAE", rdv_title: "rendez-vous collectif d'information", model: "standard"
    ).destroy!
  end
end
