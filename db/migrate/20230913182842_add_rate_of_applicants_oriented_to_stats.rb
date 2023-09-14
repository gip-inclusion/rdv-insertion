class AddRateOfApplicantsOrientedToStats < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :rate_of_applicants_oriented, :float
    add_column :stats, :rate_of_applicants_oriented_grouped_by_month, :json
  end
end
