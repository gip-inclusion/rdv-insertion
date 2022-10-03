class CreateSmsConfigurations < ActiveRecord::Migration[7.0]
  def up
    create_table :sms_configurations do |t|
      t.string :sender_name

      t.timestamps
    end

    add_reference :organisations, :sms_configuration, foreign_key: true

    InvitationParameters.where.not(sms_sender_name: nil).find_each do |invitation_parameters|
      SmsConfiguration.create!(
        sender_name: invitation_parameters.sms_sender_name,
        organisations: invitation_parameters.organisations
      )
    end

    # TODO: Re-rename invitation_parameters to letter configuration
    remove_column :invitation_parameters, :sms_sender_name
  end

  def down
    add_column :invitation_parameters, :sms_sender_name
    Organisation.where.not(sms_configuration_id: nil).find_each do |org|
      org.invitation_parameters.update!(sms_sender_name: org.sms_configuration.sender_name)
    end
    drop_table :sms_configurations
  end
end
