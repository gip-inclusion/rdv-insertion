class AddBookableByToMotifs < ActiveRecord::Migration[8.0]
  def change
    add_column :motifs, :bookable_by, :string
    remove_column :motifs, :bookable_publicly, :boolean
  end
end
