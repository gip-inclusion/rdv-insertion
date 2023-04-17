class AddShortTemplate < ActiveRecord::Migration[7.0]
  def change
    template = Template.create(
      model: "short",
      rdv_title: "rendez-vous de suivi psychologue",
      display_mandatory_warning: false,
      display_punishable_warning: false
    )

    MotifCategory.create(
      name: "Psychologue",
      short_name: "psychologue",
      template: template,
      participation_optional: true
    )
  end
end
