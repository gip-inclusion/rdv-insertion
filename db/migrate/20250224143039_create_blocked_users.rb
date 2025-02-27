class CreateBlockedUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :blocked_users do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :blocked_users, :created_at, order: { created_at: :desc }
  end
end
