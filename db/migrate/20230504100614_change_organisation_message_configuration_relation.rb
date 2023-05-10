class ChangeOrganisationMessageConfigurationRelation < ActiveRecord::Migration[7.0]
  def up
    add_reference :messages_configurations, :organisation, foreign_key: true

    Organisation.find_each do |organisation|
      next if organisation.messages_configuration_id.nil?

      mc = MessagesConfiguration.find(organisation.messages_configuration_id)
      mc.organisation_id = organisation.id
      mc.save!
    end

    remove_reference :organisations, :messages_configuration, null: false, foreign_key: true
  end

  def down
    add_reference :organisations, :messages_configuration, foreign_key: true

    MessagesConfiguration.find_each do |messages_configuration|
      next if messages_configuration.organisation_id.nil?

      organisation = Organisation.find(messages_configuration.organisation_id)
      organisation.messages_configuration_id = messages_configuration.id
      organisation.save!
    end

    remove_reference :messages_configurations, :organisation, null: false, foreign_key: true
  end
end
