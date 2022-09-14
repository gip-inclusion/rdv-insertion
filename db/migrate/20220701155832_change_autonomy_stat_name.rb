class ChangeAutonomyStatName < ActiveRecord::Migration[7.0]
  def change
    rename_column :stats, :rate_of_rdvs_created_by_user, :rate_of_autonomous_applicants
    rename_column :stats, :rate_of_rdvs_created_by_user_grouped_by_month,
                  :rate_of_autonomous_applicants_grouped_by_month
  end
end
