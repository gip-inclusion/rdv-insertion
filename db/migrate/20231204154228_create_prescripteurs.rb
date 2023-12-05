class CreatePrescripteurs < ActiveRecord::Migration[7.0]
  def change
    create_table :prescripteurs do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.references :participation, null: false, foreign_key: true
      t.bigint :rdv_solidarites_prescripteur_id

      t.timestamps
    end
  end
end
