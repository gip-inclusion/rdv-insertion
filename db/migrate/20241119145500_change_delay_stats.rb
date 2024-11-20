class ChangeDelayStats < ActiveRecord::Migration[7.1]
  def change
    add_column :stats, :rate_of_users_oriented_in_less_than_45_days, :float
    add_column :stats, :rate_of_users_oriented_in_less_than_45_days_by_month, :json
    add_column :stats, :rate_of_users_accompanied_in_less_than_15_days, :float
    add_column :stats, :rate_of_users_accompanied_in_less_than_15_days_by_month, :json

    remove_column :stats, :rate_of_users_oriented_in_less_than_30_days, :float
    remove_column :stats, :rate_of_users_oriented_in_less_than_30_days_by_month, :json
    remove_column :stats, :rate_of_users_oriented_in_less_than_15_days, :float
    remove_column :stats, :rate_of_users_oriented_in_less_than_15_days_by_month, :json
  end
end
