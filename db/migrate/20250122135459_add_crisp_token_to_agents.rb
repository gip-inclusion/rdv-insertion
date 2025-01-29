class AddCrispTokenToAgents < ActiveRecord::Migration[7.0]
  def up
    add_column :agents, :crisp_token, :string

    Agent.find_each do |agent|
      agent.update_column(:crisp_token, SecureRandom.uuid)
    end
  end

  def down
    remove_column :agents, :crisp_token
  end
end
