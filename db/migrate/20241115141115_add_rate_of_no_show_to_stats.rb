class AddRateOfNoShowToStats < ActiveRecord::Migration[7.1]
  def change
    add_column :stats, :rate_of_no_show, :float
    add_column :stats, :rate_of_no_show_grouped_by_month, :json
  end
end
