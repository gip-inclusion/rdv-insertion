class AddExternalToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :external, :boolean, default: false
  end
end
