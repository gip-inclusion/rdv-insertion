class AddResponsibleNameToOrganisations < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :responsible_name, :string
  end
end
