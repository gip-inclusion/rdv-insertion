class AddMotifCategoryForVar < ActiveRecord::Migration[7.0]
  def up
    template = Template.create!(
      model: "standard",
      rdv_title: "rendez-vous des Droits et Devoirs",
      rdv_title_by_phone: "rendez-vous téléphonique des Droits et Devoirs",
      rdv_purpose: "définir votre orientation",
      user_designation: "bénéficiaire du RSA",
      rdv_subject: "RSA",
      display_mandatory_warning: true
    )
    MotifCategory.create!(
      short_name: "rsa_droits_devoirs",
      name: "RSA - droits et devoirs",
      participation_optional: false,
      template: template
    )
  end

  def down
    MotifCategory.find_by(short_name: "rsa_droits_devoirs").destroy!
    Template.find_by(rdv_title: "rendez-vous des Droits et Devoirs").destroy!
  end
end
