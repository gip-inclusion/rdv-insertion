class RenameFollowUpsToFollowUps < ActiveRecord::Migration[7.1]
  def change
    rename_table :follow_ups, :follow_ups
    rename_column :invitations, :follow_up_id, :follow_up_id
    rename_column :participations, :follow_up_id, :follow_up_id
  end
end
