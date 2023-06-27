class AddDisplayPeLogosToMessagesConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :messages_configurations, :display_pole_emploi_logo, :boolean, default: false
  end
end
