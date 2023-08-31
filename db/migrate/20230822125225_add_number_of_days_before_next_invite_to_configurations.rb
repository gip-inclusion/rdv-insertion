class AddNumberOfDaysBeforeNextInviteToConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :number_of_days_before_next_invite, :integer, default: nil
  end
end
