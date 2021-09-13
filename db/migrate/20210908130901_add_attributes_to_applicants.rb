class AddAttributesToApplicants < ActiveRecord::Migration[6.1]
  def change
    change_table :applicants, bulk: true do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :address, :string
      t.column :phone_number_formatted, :string
      t.column :email, :string
      t.column :title, :integer
      t.column :birth_date, :date
    end
  end
end
