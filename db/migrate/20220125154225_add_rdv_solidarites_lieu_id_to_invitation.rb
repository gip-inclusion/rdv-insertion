class AddRdvSolidaritesLieuIdToInvitation < ActiveRecord::Migration[6.1]
  def up
    add_column :invitations, :rdv_solidarites_lieu_id, :bigint
    change_column :organisations, :rdv_solidarites_organisation_id, :bigint
    change_column :applicants, :rdv_solidarites_user_id, :bigint
  end

  def down
    remove_column :invitations, :rdv_solidarites_lieu_id
    change_column :organisations, :rdv_solidarites_organisation_id, :integer
    change_column :organisations, :rdv_solidarites_organisation_id, :integer
  end
end
