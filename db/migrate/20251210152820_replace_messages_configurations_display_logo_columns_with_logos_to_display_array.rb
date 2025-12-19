class ReplaceMessagesConfigurationsDisplayLogoColumnsWithLogosToDisplayArray < ActiveRecord::Migration[8.0]
  def up
    add_column :messages_configurations, :logos_to_display, :string, array: true, default: %w[department]

    MessagesConfiguration.find_each do |config|
      logos = []
      logos << "department" if config.display_department_logo
      logos << "europe" if config.display_europe_logos
      logos << "france_travail" if config.display_france_travail_logo
      config.update!(logos_to_display: logos)
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
        display_department_logo: config.logos_to_display.include?("department"),
        display_europe_logos: config.logos_to_display.include?("europe"),
        display_france_travail_logo: config.logos_to_display.include?("france_travail")
      )
    end

    remove_column :messages_configurations, :logos_to_display
  end
end
