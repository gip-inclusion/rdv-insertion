class CreateDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :departments do |t|
      t.string :name
      t.string :number
      t.string :capital
      t.string :photo_url
      t.integer :rdv_solidarites_organisation_id

      t.timestamps
    end
  end
end
