class CreatePostRdvOrientations < ActiveRecord::Migration[8.1]
  def change
    create_table :post_rdv_orientations do |t|
      t.references :participation, null: false, foreign_key: true, index: { unique: true }
      t.references :orientation_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
