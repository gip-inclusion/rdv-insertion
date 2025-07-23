class RemovePeriodicInvitesColumnsFromCategoryConfigurations < ActiveRecord::Migration[8.0]
  def change
    remove_column :category_configurations, :day_of_the_month_periodic_invites
    remove_column :category_configurations, :number_of_days_between_periodic_invites
  end
end
