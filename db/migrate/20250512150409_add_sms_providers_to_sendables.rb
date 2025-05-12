class AddSmsProvidersToSendables < ActiveRecord::Migration[8.0]
  def change
    add_column :invitations, :sms_provider, :string
    add_column :notifications, :sms_provider, :string
    up_only do
      Invitation.where(format: "sms").update_all(sms_provider: "brevo")
      Notification.where(format: "sms").update_all(sms_provider: "brevo")
    end
  end
end
