class RenamePhoneNumberFormattedToPhoneNumber < ActiveRecord::Migration[6.1]
  def change
    rename_column :applicants, :phone_number_formatted, :phone_number
  end
end
