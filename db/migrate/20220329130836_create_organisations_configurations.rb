class CreateOrganisationsConfigurations < ActiveRecord::Migration[6.1]
  def up
    create_join_table :organisations, :configurations do |t|
      t.index(
        [:organisation_id, :configuration_id],
        unique: true,
        name: "index_config_orgas_on_organisation_id_and_configuration_id"
      )
    end

    Organisation.find_each do |organisation|
      next if organisation.configuration_id.nil?

      organisation.update!(configurations: [Configuration.find(organisation.configuration_id)])
    end

    remove_reference :organisations, :configuration, foreign_key: true
  end

  def down
    add_reference :organisations, :configuration, foreign_key: true

    Organisation.find_each do |organisation|
      next if organisation.configuration_ids.empty?

      organisation.update!(configuration_id: organisation.configuration_ids.first)
    end

    drop_join_table :organisations, :configurations
  end
end
