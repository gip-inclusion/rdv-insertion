class CreateTagOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :tag_organisations do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
