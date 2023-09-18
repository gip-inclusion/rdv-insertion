class AddRsaAccompagnementMoins30AnsMotifCategory < ActiveRecord::Migration[7.0]
  def up
    template = Template.find_or_create_by!(
      model: "standard",
      rdv_title: "rendez-vous d'accompagnement",
      rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
      rdv_purpose: "démarrer un parcours d'accompagnement",
      applicant_designation: "bénéficiaire du RSA",
      rdv_subject: "RSA",
      display_mandatory_warning: true,
      punishable_warning: "votre RSA pourra être suspendu ou réduit"
    )
    MotifCategory.create!(
      short_name: "rsa_accompagnement_moins_de_30_ans",
      name: "RSA accompagnement (- de 30 ans)",
      participation_optional: false,
      template: template
    )
  end

  def down
    MotifCategory.find_by(short_name: "rsa_accompagnement_moins_de_30_ans").destroy!
  end
end
