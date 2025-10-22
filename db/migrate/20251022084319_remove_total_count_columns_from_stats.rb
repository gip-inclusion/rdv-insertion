class RemoveTotalCountColumnsFromStats < ActiveRecord::Migration[8.0]
  def change
    remove_column :stats, :users_count, :integer
    remove_column :stats, :rdvs_count, :integer
    remove_column :stats, :sent_invitations_count, :integer
    remove_column :stats, :users_with_rdv_count, :integer
  end
end
