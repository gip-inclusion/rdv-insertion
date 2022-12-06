class AddFollowUpToMotifs < ActiveRecord::Migration[7.0]
  def change
    add_column :motifs, :follow_up, :boolean, default: false
  end
end
