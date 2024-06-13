class CreateGeocodings < ActiveRecord::Migration[7.1]
  def change
    create_table :geocodings do |t|
      t.string :post_code
      t.string :city_code
      t.float :latitude
      t.float :longitude
      t.string :city
      t.string :department_number
      t.references :user, null: false, foreign_key: true
      t.string :street
      t.string :house_number
      t.string :street_ban_id

      t.timestamps
    end
  end
end
