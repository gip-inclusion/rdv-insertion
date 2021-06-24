class CreateApplicants < ActiveRecord::Migration[6.0]
  def change
    create_table :applicants do |t|
      t.string :uid
      t.integer :rdv_solidarites_user_id
      t.string :affiliation_number
      t.integer :role
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end

    add_index "applicants", ["uid"], unique: true
    add_index "applicants", ["rdv_solidarites_user_id"], unique: true
  end
end
