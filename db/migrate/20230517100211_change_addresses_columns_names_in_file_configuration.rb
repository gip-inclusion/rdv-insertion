class ChangeAddressesColumnsNamesInFileConfiguration < ActiveRecord::Migration[7.0]
  def change
    rename_column :file_configurations, :street_number_column, :address_first_field_column
    rename_column :file_configurations, :street_type_column, :address_second_field_column
    rename_column :file_configurations, :address_column, :address_third_field_column
    rename_column :file_configurations, :postal_code_column, :address_fourth_field_column
    rename_column :file_configurations, :city_column, :address_fifth_field_column
  end
end
