class RemoveMotifFromLetterConfigurations < ActiveRecord::Migration[6.1]
  def change
    remove_column :letter_configurations, :motif, :string
  end
end
