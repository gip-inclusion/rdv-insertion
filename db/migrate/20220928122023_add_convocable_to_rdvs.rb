class AddConvocableToRdvs < ActiveRecord::Migration[7.0]
  def change
    add_column :rdvs, :convocable, :boolean, default: false
  end
end
