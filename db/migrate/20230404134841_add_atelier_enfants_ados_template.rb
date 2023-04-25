class AddAtelierEnfantsAdosTemplate < ActiveRecord::Migration[7.0]
  def up
    template = Template.create!(
      model: "atelier_enfants_ados",
      rdv_title: "atelier destiné aux jeunes de ton âge",
      display_mandatory_warning: false,
      display_punishable_warning: false
    )

    MotifCategory.create!(
      name: "Atelier Enfants / Ados",
      short_name: "atelier_enfants_ados",
      template: template,
      participation_optional: true
    )
  end

  def down
    MotifCategory.find_by(short_name: "atelier_enfants_ados").destroy!
    Template.find_by(rdv_title: "atelier destiné aux jeunes de ton âge", model: "atelier_enfants_ados").destroy!
  end
end
