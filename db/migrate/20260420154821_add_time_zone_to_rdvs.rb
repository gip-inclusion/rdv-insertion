class AddTimeZoneToRdvs < ActiveRecord::Migration[8.1]
  set_lock_timeout(60_000)
  set_statement_timeout(120_000)

  def change
    add_column :rdvs, :time_zone, :string
    up_only { Rdv.update_all(time_zone: "Europe/Paris") }
  end
end
