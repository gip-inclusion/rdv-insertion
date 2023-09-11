class SplitPercentageOfNoShowInTwoStats < ActiveRecord::Migration[7.0]
  def change
    add_column :stats, :rate_of_no_show_for_convocations, :float
    add_column :stats, :rate_of_no_show_for_convocations_grouped_by_month, :json
    add_column :stats, :rate_of_no_show_for_invitations, :float
    add_column :stats, :rate_of_no_show_for_invitations_grouped_by_month, :json
    remove_column :stats, :percentage_of_no_show, :float
    remove_column :stats, :percentage_of_no_show_grouped_by_month, :json
  end
end
