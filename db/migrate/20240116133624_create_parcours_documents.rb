class CreateParcoursDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :parcours_documents do |t|
      t.references :department, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.string :type, index: true

      t.timestamps
    end
  end
end
