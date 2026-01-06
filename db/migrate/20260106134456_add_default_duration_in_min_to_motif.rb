class AddDefaultDurationInMinToMotif < ActiveRecord::Migration[8.0]
  def change
    add_column :motifs, :default_duration_in_min, :integer, default: 30, null: false
  end
end
