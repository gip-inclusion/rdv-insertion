class AddColumnsToStats < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :users_with_rdv_count, :integer
    add_column :stats, :users_with_rdv_count_grouped_by_month, :json
  end
end
