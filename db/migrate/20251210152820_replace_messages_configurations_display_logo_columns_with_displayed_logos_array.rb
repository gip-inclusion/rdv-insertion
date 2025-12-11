class ReplaceMessagesConfigurationsDisplayLogoColumnsWithDisplayedLogosArray < ActiveRecord::Migration[8.0]
  def up
    add_column :messages_configurations, :displayed_logos, :string, array: true, default: []

    MessagesConfiguration.find_each do |config|
      logos = []
      logos << "department" if config.display_department_logo
      logos << "europe" if config.display_europe_logos
      logos << "france_travail" if config.display_france_travail_logo
      config.update!(displayed_logos: logos)
    end

    remove_column :messages_configurations, :display_europe_logos
    remove_column :messages_configurations, :display_department_logo
    remove_column :messages_configurations, :display_france_travail_logo
  end

  def down
    add_column :messages_configurations, :display_europe_logos, :boolean, default: false
    add_column :messages_configurations, :display_department_logo, :boolean, default: true
    add_column :messages_configurations, :display_france_travail_logo, :boolean, default: false

    MessagesConfiguration.find_each do |config|
      config.update_columns(
        display_department_logo: config.displayed_logos.include?("department"),
        display_europe_logos: config.displayed_logos.include?("europe"),
        display_france_travail_logo: config.displayed_logos.include?("france_travail")
      )
    end

    remove_column :messages_configurations, :displayed_logos
  end
end
