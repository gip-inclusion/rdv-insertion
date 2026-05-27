class AddSessionKeyToAgents < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :session_key, :string
  end
end
