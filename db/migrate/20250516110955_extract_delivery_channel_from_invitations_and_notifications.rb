class ExtractDeliveryChannelFromInvitationsAndNotifications < ActiveRecord::Migration[8.0]
  def up
    create_table :deliveries do |t|
      t.string :delivery_channel_type
      t.bigint :delivery_channel_id
      t.references :deliverable, polymorphic: true, null: false
      t.timestamps
    end

    create_table :delivery_sms_deliveries do |t|
      t.string :provider, default: "brevo"
      t.string :delivery_status
      t.datetime :last_brevo_webhook_received_at
      t.timestamps
    end

    create_table :delivery_email_deliveries do |t|
      t.string :provider, default: "brevo"
      t.string :delivery_status
      t.datetime :last_brevo_webhook_received_at
      t.timestamps
    end

    create_table :delivery_postal_deliveries do |t|
      t.timestamps
    end

    add_index :deliveries, [:delivery_channel_type, :delivery_channel_id]

    remove_column :invitations, :delivery_status, :string
    remove_column :invitations, :last_brevo_webhook_received_at, :datetime
    remove_column :notifications, :delivery_status, :string
    remove_column :notifications, :last_brevo_webhook_received_at, :datetime

    say_with_time "Migrating invitations to deliveries" do
      Invitation.find_each do |invitation|
        channel = case invitation.format
                  when "sms"
                    Delivery::SmsDelivery.new(
                      provider: "brevo",
                      delivery_status: invitation.delivery_status,
                      last_brevo_webhook_received_at: invitation.last_brevo_webhook_received_at
                    )
                  when "email"
                    Delivery::EmailDelivery.new(
                      provider: "brevo",
                      delivery_status: invitation.delivery_status,
                      last_brevo_webhook_received_at: invitation.last_brevo_webhook_received_at
                    )
                  when "postal"
                    Delivery::PostalDelivery.new
                  end

        Delivery.new(
          deliverable: invitation,
          delivery_channel: channel
        ).save!
      end
    end

    say_with_time "Migrating notifications to deliveries" do
      Notification.find_each do |notification|
        channel = case notification.format
                  when "sms"
                    Delivery::SmsDelivery.new(
                      provider: "brevo",
                      delivery_status: notification.delivery_status,
                      last_brevo_webhook_received_at: notification.last_brevo_webhook_received_at
                    )
                  when "email"
                    Delivery::EmailDelivery.new(
                      provider: "brevo",
                      delivery_status: notification.delivery_status,
                      last_brevo_webhook_received_at: notification.last_brevo_webhook_received_at
                    )
                  when "postal"
                    Delivery::PostalDelivery.new
                  end

        Delivery.new(
          deliverable: notification,
          delivery_channel: channel
        ).save!
      end
    end
  end

  def down
    add_column :invitations, :delivery_status, :string
    add_column :invitations, :last_brevo_webhook_received_at, :datetime
    add_column :notifications, :delivery_status, :string
    add_column :notifications, :last_brevo_webhook_received_at, :datetime

    say_with_time "Restoring invitations delivery fields" do
      Invitation.includes(delivery: :delivery_channel).find_each do |invitation|
        channel = invitation.delivery&.delivery_channel
        next unless channel.respond_to?(:delivery_status)

        invitation.update!(
          delivery_status: channel.delivery_status,
          last_brevo_webhook_received_at: channel.last_brevo_webhook_received_at
        )
      end
    end

    say_with_time "Restoring notifications delivery fields" do
      Notification.includes(delivery: :delivery_channel).find_each do |notification|
        channel = notification.delivery&.delivery_channel
        next unless channel.respond_to?(:delivery_status)

        notification.update!(
          delivery_status: channel.delivery_status,
          last_brevo_webhook_received_at: channel.last_brevo_webhook_received_at
        )
      end
    end

    drop_table :deliveries
    drop_table :delivery_sms_deliveries
    drop_table :delivery_email_deliveries
    drop_table :delivery_postal_deliveries
  end
end
