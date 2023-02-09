class AddParticipationOptionalToMotifCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :motif_categories, :participation_optional, :boolean, default: false
    up_only do
      MotifCategory.where(
        short_name: %w[rsa_insertion_offer rsa_atelier_competences rsa_atelier_rencontres_pro]
      ).update_all(participation_optional: true)
    end
  end
end
