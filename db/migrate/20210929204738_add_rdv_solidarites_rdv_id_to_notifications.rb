class AddRdvSolidaritesRdvIdToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :rdv_solidarites_rdv_id, :bigint
  end
end
