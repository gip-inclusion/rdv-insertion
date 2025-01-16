class CreateUserSaveAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :user_save_attempts do |t|
      t.boolean :success
      t.references :user_row, null: false, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true
      t.string :error_type
      t.string :service_errors, array: true, default: []

      t.timestamps
    end
  end
end
