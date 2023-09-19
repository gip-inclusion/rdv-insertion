class AddPeriodicInvitesColumnsToConfigurations < ActiveRecord::Migration[7.0]
  def change
    remove_column :configurations, :number_of_days_before_next_invite, :integer
    add_column :configurations, :number_of_days_between_periodic_invites, :integer
    add_column :configurations, :day_of_the_month_periodic_invites, :integer
  end
end
