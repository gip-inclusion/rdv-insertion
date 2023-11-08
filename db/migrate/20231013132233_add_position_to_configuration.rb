class AddPositionToConfiguration < ActiveRecord::Migration[7.0]
  # rubocop:disable Metrics/AbcSize
  def change
    add_column :configurations, :position, :integer
    add_column :configurations, :department_position, :integer

    ordered_motifs = %w[
      rsa_integration_information
      rsa_droits_devoirs
      rsa_orientation
      rsa_orientation_file_active
      rsa_orientation_france_travail
      rsa_orientation_coaching
      rsa_orientation_freelance
      rsa_orientation_on_phone_platform
      rsa_accompagnement
      rsa_accompagnement_social
      rsa_accompagnement_sociopro
      rsa_accompagnement_moins_de_30_ans
      rsa_renouvellement_cer
      accompagnement_global
      rsa_follow_up
      rsa_suivi_plie
      rsa_cer_signature
      rsa_insertion_offer
      rsa_atelier_competences
      rsa_atelier_rencontres_pro
      rsa_atelier_collectif_mandatory
      rsa_main_tendue
      rsa_spie
      siae_interview
      siae_collective_information
      siae_follow_up
    ]

    Organisation.all.each do |organisation|
      ordered_motifs.each_with_index do |motif_name, index|
        motif = organisation.motif_categories.find_by(short_name: motif_name)

        next if motif.nil?

        organisation.configurations.find_by(motif_category: motif).update_column(:position, index)
      end
    end

    Department.all.each do |department|
      ordered_motifs.each_with_index do |motif_name, index|
        motif = department.motif_categories.find_by(short_name: motif_name)

        next if motif.nil?

        department.configurations.find_by(motif_category: motif).update_column(:department_position, index)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
