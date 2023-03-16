class ChangeColumnNamesFormatForFileConfigurations < ActiveRecord::Migration[7.0]
  COLUMN_NAMES = [:title, :first_name, :last_name, :role, :email, :phone_number, :birth_date, :birth_name,
                  :street_number, :street_type, :address, :postal_code, :city, :department_internal_id,
                  :affiliation_number, :rights_opening_date, :organisation_search_terms, :referent_email].freeze

  # rubocop:disable Metrics/AbcSize
  def up
    COLUMN_NAMES.each do |column_name|
      add_column :file_configurations, "#{column_name}_column".to_sym, :string
    end

    FileConfiguration.find_each do |file_configuration|
      COLUMN_NAMES.each do |column_name|
        required_column_names = file_configuration.read_attribute(:column_names)["required"]
        optional_column_names = file_configuration.read_attribute(:column_names)["optional"]
        value = if required_column_names.present? && required_column_names[column_name.to_s]
                  required_column_names[column_name.to_s]
                elsif optional_column_names.present? && optional_column_names[column_name.to_s]
                  optional_column_names[column_name.to_s]
                end
        file_configuration["#{column_name}_column"] = value
      end
      file_configuration.save!(validate: false)
    end

    remove_column :file_configurations, :column_names
  end
  # rubocop:enable Metrics/AbcSize

  def down
    add_column :file_configurations, :column_names, :jsonb, null: false, default: { required: {}, optional: {} }

    FileConfiguration.find_each do |file_configuration|
      COLUMN_NAMES.each do |column_name|
        if file_configuration["#{column_name}_column"].present?
          file_configuration.read_attribute(:column_names)["required"][column_name.to_s] = \
            file_configuration["#{column_name}_column"]
        end
      end
      file_configuration.save!(validate: false)
    end

    COLUMN_NAMES.each do |column_name|
      remove_column :file_configurations, "#{column_name}_column".to_sym
    end
  end
end
