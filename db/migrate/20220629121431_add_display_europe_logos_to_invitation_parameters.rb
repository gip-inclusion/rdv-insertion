class AddDisplayEuropeLogosToInvitationParameters < ActiveRecord::Migration[7.0]
  def change
    add_column :invitation_parameters, :display_europe_logos, :boolean, default: false
  end
end
