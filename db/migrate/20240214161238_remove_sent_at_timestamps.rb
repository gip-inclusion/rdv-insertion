class RemoveSentAtTimestamps < ActiveRecord::Migration[7.0]
  def up
    Notification.where(sent_at: nil).destroy_all
    Invitation.where(sent_at: nil).destroy_all

    remove_column :invitations, :sent_at, :datetime
    remove_column :notifications, :sent_at, :datetime
  end

  def down
    add_column :invitations, :sent_at, :datetime
    add_column :notifications, :sent_at, :datetime

    Invitation.find_each { |invitation| invitation.update_column(:sent_at, invitation.created_at) }
    Notification.find_each { |notification| notification.update_column(:sent_at, notification.created_at) }
  end
end
