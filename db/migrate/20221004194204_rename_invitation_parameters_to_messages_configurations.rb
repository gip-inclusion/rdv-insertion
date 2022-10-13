class RenameInvitationParametersToMessagesConfigurations < ActiveRecord::Migration[7.0]
  def change
    rename_table :invitation_parameters, :messages_configurations
    rename_column :organisations, :invitation_parameters_id, :messages_configuration_id
  end
end
