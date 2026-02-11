class AddVisioUrlToRdvs < ActiveRecord::Migration[8.1]
  def change
    add_column :rdvs, :visio_url, :string
  end
end
