class AddCguAcceptedAtToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :cgu_accepted_at, :datetime
  end
end
