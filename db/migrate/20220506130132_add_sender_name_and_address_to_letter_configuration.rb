class AddSenderNameAndAddressToLetterConfiguration < ActiveRecord::Migration[7.0]
  def change
    add_column :letter_configurations, :sender_name, :string
    add_column :letter_configurations, :sender_address_lines, :string, array: true
  end
end
