class ReplaceInvitationsTriggerWithOrigin < ActiveRecord::Migration[8.1]
  set_lock_timeout(60_000)
  set_statement_timeout(120_000)

  def up
    add_column :invitations, :origin, :string
    add_index :invitations, :origin

    Invitation.where(trigger: "reminder").update_all(origin: "reminder")
    Invitation.where(trigger: "periodic").update_all(origin: "legacy_triggered_by_periodic_job")
    Invitation.where(trigger: "manual").update_all(origin: "legacy_triggered_by_agent")

    upload_invitation_ids = UserListUpload::InvitationAttempt.where.not(invitation_id: nil).select(:invitation_id)
    Invitation.where(id: upload_invitation_ids).update_all(origin: "user_list_upload")

    change_column_null :invitations, :origin, false
    remove_index :invitations, :trigger
    remove_column :invitations, :trigger
  end

  def down
    add_column :invitations, :trigger, :string, null: false, default: "manual"
    add_index :invitations, :trigger

    Invitation.where(origin: "reminder").update_all(trigger: "reminder")
    Invitation.where(origin: "legacy_triggered_by_periodic_job").update_all(trigger: "periodic")

    remove_column :invitations, :origin
  end
end
