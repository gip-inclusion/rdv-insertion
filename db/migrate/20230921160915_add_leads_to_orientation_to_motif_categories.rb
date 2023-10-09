class AddLeadsToOrientationToMotifCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :motif_categories, :leads_to_orientation, :boolean, default: false

    MotifCategory.where(short_name: %w[
                          rsa_orientation
                          rsa_orientation_on_phone_platform
                          rsa_atelier_collectif_mandatory
                          rsa_spie
                          rsa_integration_information
                          rsa_orientation_coaching
                          rsa_orientation_freelance
                          rsa_orientation_france_travail
                          rsa_orientation_file_active
                          rsa_droits_devoirs
                        ])
                 .update_all(leads_to_orientation: true)
  end
end
