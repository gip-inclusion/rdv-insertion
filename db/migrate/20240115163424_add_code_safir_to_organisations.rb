class AddCodeSafirToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :safir_code, :string
  end
end
