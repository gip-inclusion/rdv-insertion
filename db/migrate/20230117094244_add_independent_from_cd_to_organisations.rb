class AddIndependentFromCdToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :independent_from_cd, :boolean, default: false
  end
end
