class AddMessagesConfigurationsToAllOrganisations < ActiveRecord::Migration[7.0]
  def change
    Organisation.where.missing(:messages_configuration).find_each do |organisation|
      organisation.build_messages_configuration
      organisation.save
    end
  end
end
