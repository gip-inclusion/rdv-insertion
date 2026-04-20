class AddTimeZoneToRdvs < ActiveRecord::Migration[8.1]
  def change
    add_column :rdvs, :time_zone, :string
    up_only { Rdv.update_all(time_zone: "Europe/Paris") }
  end
end
