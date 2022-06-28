class AddValidUntilToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :valid_until, :datetime
    change_column_default :configurations, :number_of_days_before_action_required, from: 3, to: 10
    up_only do
      ::Configuration.find_each do |c|
        c.update! number_of_days_before_action_required: 10 if c.number_of_days_before_action_required <= 3
      end
    end
  end
end
