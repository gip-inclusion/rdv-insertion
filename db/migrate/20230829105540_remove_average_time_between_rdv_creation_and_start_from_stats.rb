class RemoveAverageTimeBetweenRdvCreationAndStartFromStats < ActiveRecord::Migration[7.0]
  def up
    remove_column :stats, :average_time_between_rdv_creation_and_start_in_days
    remove_column :stats, :average_time_between_rdv_creation_and_start_in_days_by_month
  end

  def down
    add_column :stats, :average_time_between_rdv_creation_and_start_in_days, :float
    add_column :stats, :average_time_between_rdv_creation_and_start_in_days_by_month, :json
  end
end
