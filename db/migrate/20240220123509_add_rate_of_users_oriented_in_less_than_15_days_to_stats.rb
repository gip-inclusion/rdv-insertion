class AddRateOfUsersOrientedInLessThan15DaysToStats < ActiveRecord::Migration[7.1]
  def change
    add_column :stats, :rate_of_users_oriented_in_less_than_15_days, :float
    add_column :stats, :rate_of_users_oriented_in_less_than_15_days_by_month, :json
  end
end
