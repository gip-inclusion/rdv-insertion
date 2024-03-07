class AddOldRdvSolidaritesUserIdToUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :users, :old_rdv_solidarites_user_id, :bigint

    User.where.not(deleted_at: nil).find_each do |user|
      user.update_columns(
        old_rdv_solidarites_user_id: user.rdv_solidarites_user_id,
        rdv_solidarites_user_id: nil
      )
    end
  end

  def down
    User.where.not(deleted_at: nil).find_each do |user|
      user.update_columns(
        rdv_solidarites_user_id: user.old_rdv_solidarites_user_id
      )
    end

    remove_column :users, :old_rdv_solidarites_user_id
  end
end
