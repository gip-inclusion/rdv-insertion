class CreateInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :invitations do |t|
      t.integer :format
      t.string :link
      t.string :token
      t.datetime :sent_at
      t.references :applicant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
