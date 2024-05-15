class AddOrganisationTypeToOrganisation < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :organisation_type, :string
  end
end
