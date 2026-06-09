class CreateUserListUploadCreneauxSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :user_list_upload_creneaux_snapshots do |t|
      t.references :user_list_upload, null: false, foreign_key: true, type: :uuid
      t.integer :number_of_creneaux_available, null: false

      t.timestamps
    end
  end
end
