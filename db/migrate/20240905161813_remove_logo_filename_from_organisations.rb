class RemoveLogoFilenameFromOrganisations < ActiveRecord::Migration[7.1]
  def change
    remove_column :organisations, :logo_filename, :string
  end
end
