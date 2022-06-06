class AddHelpAddressToConfiguration < ActiveRecord::Migration[7.0]
  def change
    remove_column :letter_configurations, :sender_address_lines, :string
    add_column :configurations, :help_address, :string
  end
end
