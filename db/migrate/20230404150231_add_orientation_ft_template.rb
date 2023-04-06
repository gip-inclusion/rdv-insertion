class AddOrientationFtTemplate < ActiveRecord::Migration[7.0]
  def up
    add_column :templates, :custom_sentence, :text

    template = Template.create!(
      model: "standard",
      rdv_title: "rendez-vous d'orientation",
      rdv_title_by_phone: "rendez-vous d'orientation téléphonique",
      rdv_purpose: "démarrer un parcours d'accompagnement",
      applicant_designation: "bénéficiaire du RSA",
      rdv_subject: "RSA",
      custom_sentence: "Dans le cadre du projet 'France Travail', ce rendez-vous sera réalisé par deux professionnels" \
                       " de l’insertion (l’un de Pôle emploi, l’autre du Conseil départemental) et permettra de mieux" \
                       " comprendre votre situation afin de vous proposer un accompagnement adapté.",
      display_mandatory_warning: true,
      display_punishable_warning: false
    )

    MotifCategory.create!(
      name: "RSA orientation France Travail",
      short_name: "rsa_orientation_france_travail",
      template: template,
      participation_optional: false
    )
  end

  def down
    MotifCategory.find_by(short_name: "rsa_orientation_france_travail").destroy
    Template.find_by(rdv_title: "premier rendez-vous d'orientation France Travail", model: "standard").destroy

    remove_column :templates, :custom_sentence
  end
end
