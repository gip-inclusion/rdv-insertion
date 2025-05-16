class ExtractDeliveryChannelFromInvitationsAndNotifications < ActiveRecord::Migration[8.0]
  def up
    create_table :deliveries do |t|
      t.string :delivery_method_type
      t.bigint :delivery_method_id
      t.references :sendable, polymorphic: true, null: false
      t.timestamps
    end

    create_table :sms_deliveries do |t|
      t.string :provider, default: "brevo"
      t.string :delivery_status
      t.datetime :last_brevo_webhook_received_at
      t.timestamps
    end

    create_table :email_deliveries do |t|
      t.string :provider, default: "brevo"
      t.string :delivery_status
      t.datetime :last_brevo_webhook_received_at
      t.timestamps
    end

    create_table :letter_deliveries do |t|
      t.timestamps
    end

    add_index :deliveries, [:delivery_method_type, :delivery_method_id]

    say_with_time "Migrating invitations to deliveries" do
      Invitation.find_each do |invitation|
        delivery_method_attrs = extract_method_attributes(invitation.format, invitation)
        Delivery.create!(
          sendable: invitation,
          delivery_method_type: delivery_method_attrs[:type],
          delivery_method_attributes: delivery_method_attrs[:attributes]
        )
      end
    end

    say_with_time "Migrating notifications to deliveries" do
      Notification.find_each do |notification|
        delivery_method_attrs = extract_delivery_method_attributes(notification.format, notification)
        Delivery.create!(
          sendable: notification,
          delivery_method_type: delivery_method_attrs[:type],
          delivery_method_attributes: delivery_method_attrs[:attributes]
        )
      end
    end
  end

  def down
    drop_table :deliveries
    drop_table :sms_deliveries
    drop_table :email_deliveries
    drop_table :letter_deliveries
  end

  private

  def extract_delivery_method_attributes(format, record)
    case format
    when "sms"
      {
        type: "Delivery::BySms",
        attributes: {
          provider: "brevo",
          delivery_status: record[:delivery_status],
          last_brevo_webhook_received_at: record[:last_brevo_webhook_received_at]
        }
      }
    when "email"
      {
        type: "Delivery::ByEmail",
        attributes: {
          provider: "brevo",
          delivery_status: record[:delivery_status],
          last_brevo_webhook_received_at: record[:last_brevo_webhook_received_at]
        }
      }
    when "postal", "letter"
      {
        type: "Delivery::ByLetter",
        attributes: {}
      }
    else
      raise "Unknown format: #{format}"
    end
  end
end
