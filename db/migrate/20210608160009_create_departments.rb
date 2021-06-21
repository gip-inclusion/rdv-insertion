class CreateDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :departments do |t|
      t.string :name
      t.string :number
      t.string :capital
      t.integer :rdv_solidarites_organisation_id

      t.timestamps
    end

    add_index "departments", ["rdv_solidarites_organisation_id"], unique: true
  end
end
