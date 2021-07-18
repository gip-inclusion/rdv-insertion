class CreateConfiguration < ActiveRecord::Migration[6.0]
  def change
    create_table :configurations do |t|
      t.string :sheet_name
      t.integer :invitation_format
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end
  end
end
