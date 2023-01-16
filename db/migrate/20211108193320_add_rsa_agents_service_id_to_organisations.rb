class AddRsaAgentsServiceIdToOrganisations < ActiveRecord::Migration[6.1]
  # Agents and motifs can be on "Service Social" and not in "Service RSA" so we have to save the service id for the org

  def change
    add_column :organisations, :rsa_agents_service_id, :string, default: ENV["RDV_SOLIDARITES_RSA_SERVICE_ID"]
  end
end
