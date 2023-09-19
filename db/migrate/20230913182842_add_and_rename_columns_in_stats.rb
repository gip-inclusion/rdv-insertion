class AddAndRenameColumnsInStats < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :rate_of_applicants_oriented, :float
    add_column :stats, :rate_of_applicants_oriented_grouped_by_month, :json
    rename_column :stats, :rate_of_applicants_with_rdv_seen_in_less_than_30_days,
                  :rate_of_applicants_oriented_in_less_than_30_days
    rename_column :stats, :rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month,
                  :rate_of_applicants_oriented_in_less_than_30_days_by_month
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
                          rsa_accompagnement
                          rsa_accompagnement_social
                          rsa_accompagnement_sociopro
                          rsa_accompagnement_moins_de_30_ans
                        ])
                 .update_all(leads_to_orientation: true)
  end
end
