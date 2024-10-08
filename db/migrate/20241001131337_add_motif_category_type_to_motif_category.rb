class AddMotifCategoryTypeToMotifCategory < ActiveRecord::Migration[7.1]
  def change
    add_column :motif_categories, :motif_category_type, :string, default: "Autre", null: false
  end
end
