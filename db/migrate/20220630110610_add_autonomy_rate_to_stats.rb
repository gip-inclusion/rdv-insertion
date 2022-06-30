class AddAutonomyRateToStats < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :rate_of_rdvs_taken_in_autonomy_by_user, :float
    add_column :stats, :rate_of_rdvs_taken_in_autonomy_by_user_grouped_by_month, :json

    up_only do
      UpsertStatsJob.perform_async
    end
  end
end
