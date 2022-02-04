class ChangeInvitationFormatInConfig < ActiveRecord::Migration[6.1]
  def up
    add_column :configurations, :invitation_formats, :string, array: true, null: false, default: %w[sms email postal]

    Configuration.find_each do |config|
      case config.invitation_format
      when "sms"
        config.invitation_formats = %w[sms]
      when "email"
        config.invitation_formats = %w[email]
      when "sms_and_email"
        config.invitation_formats = %w[sms email]
      when "link_only"
        config.invitation_formats = %w[postal]
      when "no_invitation"
        config.invitation_formats = []
      end

      config.save!
    end

    remove_column :configurations, :invitation_format
  end

  def down
    add_column :configurations, :invitation_format

    Configuration.find_each do |config|
      case config.invitation_formats
      when ["sms"]
        config.invitation_format = "sms"
      when ["email"]
        config.invitation_format = "email"
      when %w[sms email]
        config.invitation_format = "sms_and_email"
      when %w[sms email postal]
        config.invitation_format = "all"
      when %w[postal]
        config.invitation_format = "link_only"
      when []
        config.invitation_format = "no_invitation"
      end

      config.save!
    end

    remove_column :configurations, :invitation_formats, :string, array: true, null: false, default: %w[sms email postal]
  end
end
