class CreateTagApplicants < ActiveRecord::Migration[7.0]
  def change
    create_table :tag_applicants do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :applicant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
