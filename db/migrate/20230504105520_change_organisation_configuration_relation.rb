class ChangeOrganisationConfigurationRelation < ActiveRecord::Migration[7.0]
  def up
    add_reference :configurations, :organisation, foreign_key: true

    ConfigurationsOrganisation.all.each do |config_org|
      configuration = ::Configuration.find(config_org.configuration_id)
      configuration.organisation_id = config_org.organisation_id
      configuration.save!
    end

    drop_table :configurations_organisations
  end

  def down
    create_join_table :organisations, :configurations do |t|
      t.index(
        [:organisation_id, :configuration_id],
        unique: true,
        name: "index_config_orgas_on_organisation_id_and_configuration_id"
      )
    end

    ::Configuration.find_each do |configuration|
      configuration.update!(organisations: [Organisation.find(configuration.organisation_id)])
    end

    remove_reference :configurations, :organisation, null: false, foreign_key: true
  end
end
