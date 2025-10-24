class CreateUserListUploadProcessingLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :user_list_upload_processing_logs do |t|
      t.datetime :user_saves_triggered_at
      t.datetime :user_saves_started_at
      t.datetime :user_saves_ended_at
      t.datetime :invitations_triggered_at
      t.datetime :invitations_started_at
      t.datetime :invitations_ended_at
      t.references :user_list_upload, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
