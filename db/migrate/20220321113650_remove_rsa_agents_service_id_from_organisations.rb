class RemoveRsaAgentsServiceIdFromOrganisations < ActiveRecord::Migration[6.1]
  def up
    remove_column :organisations, :rsa_agents_service_id
  end

  def down
    add_column :organisations, :rsa_agents_service_id
  end
end
