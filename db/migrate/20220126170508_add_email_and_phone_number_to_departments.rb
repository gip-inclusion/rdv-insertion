class AddEmailAndPhoneNumberToDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :departments, :email, :string
    add_column :departments, :phone_number, :string
  end
end
