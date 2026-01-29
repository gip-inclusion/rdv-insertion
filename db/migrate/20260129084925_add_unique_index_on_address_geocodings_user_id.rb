class AddUniqueIndexOnAddressGeocodingsUserId < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      DELETE FROM address_geocodings
      WHERE id NOT IN (
        SELECT DISTINCT ON (user_id) id
        FROM address_geocodings
        ORDER BY user_id, updated_at DESC
      )
    SQL

    remove_index :address_geocodings, :user_id
    add_index :address_geocodings, :user_id, unique: true
  end

  def down
    remove_index :address_geocodings, :user_id
    add_index :address_geocodings, :user_id
  end
end
