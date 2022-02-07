class ChangeInvitationFormatInConfig < ActiveRecord::Migration[6.1]
  def up
    add_column :configurations, :invitation_formats, :string, array: true, null: false, default: %w[sms email postal]

    Configuration.find_each do |config|
      case config.invitation_format
      when 0
        config.invitation_formats = %w[sms]
      when 1
        config.invitation_formats = %w[email]
      when 2
        config.invitation_formats = %w[sms email]
      when 3
        config.invitation_formats = %w[postal]
      when 4
        config.invitation_formats = []
      end

      config.save!
    end

    remove_column :configurations, :invitation_format
  end

  def down
    add_column :configurations, :invitation_format, :integer

    Configuration.find_each do |config|
      case config.invitation_formats
      when 0
        config.invitation_format = "sms"
      when 1
        config.invitation_format = "email"
      when 2
        config.invitation_format = "sms_and_email"
      when 3
        config.invitation_format = "link_only"
      when 4
        config.invitation_format = "all"
      when 5
        config.invitation_format = "no_invitation"
      end

      config.save!
    end

    remove_column :configurations, :invitation_formats, :string, array: true, null: false, default: %w[sms email postal]
  end
end
