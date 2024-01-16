class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.string :document_type

      t.timestamps
    end
  end
end
