class AddWebsiteToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :website, :string
  end
end
