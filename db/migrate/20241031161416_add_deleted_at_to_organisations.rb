class AddDeletedAtToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :archived_at, :datetime
    add_index :organisations, :archived_at

    up_only do
      Organisation.where.missing(:agents).update_all(archived_at: Time.zone.now)
    end
  end
end
