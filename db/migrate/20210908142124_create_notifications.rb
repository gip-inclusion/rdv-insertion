class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :applicant, null: false, foreign_key: true
      t.integer :event
      t.datetime :sent_at

      t.timestamps
    end
  end
end
