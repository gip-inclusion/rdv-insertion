class AddPhoneNumberToConfiguration < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :phone_number, :string
  end
end
