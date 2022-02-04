class ChangeInvitationFormatInConfig < ActiveRecord::Migration[6.1]
  def change
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
end
