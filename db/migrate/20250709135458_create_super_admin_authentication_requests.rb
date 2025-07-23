class CreateSuperAdminAuthenticationRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :super_admin_authentication_requests do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :verified_at
      t.datetime :invalidated_at
      t.integer :verification_attempts, default: 0, null: false

      t.timestamps
    end
  end
end
