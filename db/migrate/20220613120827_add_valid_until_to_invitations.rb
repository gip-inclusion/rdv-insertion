class AddValidUntilToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :valid_until, :datetime
    change_column_default :configurations, :number_of_days_before_action_required, from: 3, to: 10
    up_only do
      ::Configuration.find_each { |c| c.update! number_of_days_before_action_required: 10 }
    end
  end
end
