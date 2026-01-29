class AddUniqueIndexOnAddressGeocodingsUserId < ActiveRecord::Migration[8.1]
  def up
    remove_index :address_geocodings, :user_id
    add_index :address_geocodings, :user_id, unique: true
  end

  def down
    remove_index :address_geocodings, :user_id
    add_index :address_geocodings, :user_id
  end
end
