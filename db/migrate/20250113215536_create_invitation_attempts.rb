class CreateInvitationAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :invitation_attempts do |t|
      t.boolean :success
      t.references :user_row, null: false, foreign_key: true
      t.references :invitation, foreign_key: true
      t.string :service_errors, array: true, default: []
      t.string :format

      t.timestamps
    end
  end
end
