class AddRegionAndPhoneNumberToDepartment < ActiveRecord::Migration[6.0]
  def change
    change_table :departments, bulk: true do |t|
      t.column :region, :string
      t.column :phone_number, :string
    end
  end
end
