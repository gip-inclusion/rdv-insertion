class RemoveLeadsToOrienationFromMotifCategory < ActiveRecord::Migration[7.1]
  def up
    MotifCategory.where(leads_to_orientation: true).update_all(motif_category_type: "rsa_orientation")
    remove_column :motif_categories, :leads_to_orientation, :boolean, default: false
  end

  def down
    add_column :motif_categories, :leads_to_orientation, :boolean, default: false
    MotifCategory.where(motif_category_type: "rsa_orientation").update_all(leads_to_orientation: true)
  end
end
