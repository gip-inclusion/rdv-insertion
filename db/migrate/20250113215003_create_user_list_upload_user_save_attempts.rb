class CreateUserListUploadUserSaveAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :user_list_upload_user_save_attempts do |t|
      t.boolean :success
      t.references :user, foreign_key: true
      t.uuid :user_row_id, null: false
      t.string :error_type
      t.string :internal_error_message
      t.string :service_errors, array: true, default: []

      t.timestamps
    end

    add_foreign_key :user_list_upload_user_save_attempts, :user_list_upload_user_rows, column: :user_row_id
    add_index :user_list_upload_user_save_attempts, :user_row_id
  end
end
