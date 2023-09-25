class AddAndRenameColumnsInStat < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :rate_of_users_oriented, :float
    add_column :stats, :rate_of_users_oriented_grouped_by_month, :json
    rename_column :stats, :rate_of_users_with_rdv_seen_in_less_than_30_days,
                  :rate_of_users_oriented_in_less_than_30_days
    rename_column :stats, :rate_of_users_with_rdv_seen_in_less_than_30_days_by_month,
                  :rate_of_users_oriented_in_less_than_30_days_by_month

  end
end
