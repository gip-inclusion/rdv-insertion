class AddOrientationsMotifCategories < ActiveRecord::Migration[7.0]
  def up
    MotifCategory.create!(
      name: "RSA orientation - coaching emploi",
      short_name: "rsa_orientation_coaching",
      template: Template.find_by(rdv_title: "rendez-vous d'orientation"),
      participation_optional: false
    )

    MotifCategory.create!(
      name: "RSA orientation - travailleurs indépendants",
      short_name: "rsa_orientation_freelance",
      template: Template.find_by(rdv_title: "rendez-vous d'orientation"),
      participation_optional: false
    )
  end

  def down
    MotifCategory.find_by(short_name: "rsa_orientation_coaching").destroy!
    MotifCategory.find_by(short_name: "rsa_orientation_freelance").destroy!
  end
end
