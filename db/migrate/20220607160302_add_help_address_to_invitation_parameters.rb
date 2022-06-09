class AddHelpAddressToInvitationParameters < ActiveRecord::Migration[7.0]
  def change
    remove_column :invitation_parameters, :sender_address_lines, :string
    add_column :invitation_parameters, :help_address, :string
  end
end
