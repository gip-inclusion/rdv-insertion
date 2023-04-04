class AddOrientationFtTemplate < ActiveRecord::Migration[7.0]
  def change
    template = Template.create(
      model: "orientation_france_travail",
      rdv_title: "premier rendez-vous d'orientation France Travail",
      applicant_designation: "bénéficiaire du RSA",
      rdv_subject: "RSA",
      display_mandatory_warning: true,
      display_punishable_warning: false
    )

    MotifCategory.create(
      name: "RSA Orientation France Travail",
      short_name: "rsa_orientation_france_travail",
      template: template,
      participation_optional: false
    )
  end
end
