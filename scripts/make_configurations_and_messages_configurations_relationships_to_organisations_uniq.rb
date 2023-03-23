# rails runner scripts/make_configurations_and_messages_configurations_relationships_to_organisations_uniq.rb

ActiveRecord::Base.transaction do
  puts "Making configurations uniq..."
  puts "-------"
  puts "#{Configuration.count} configurations and #{ConfigurationsOrganisation.count} configurations_organisations"
  Configuration.find_each do |configuration|
    puts "Configuration #{configuration.id} is linked to #{configuration.organisations.length} organisations"
    if configuration.organisations.blank?
      configuration.destroy!
      next
    end

    next if configuration.organisations.length < 2

    puts "Creating new configurations..."
    organisations = configuration.organisations.to_a
    new_configurations = []
    configuration.organisations.length.times do
      c = Configuration.create!(configuration.attributes.except("id", "created_at", "updated_at"))
      new_configurations << c
      puts "New configuration created"
    end
    puts "Destroying old configuration..."
    configuration.destroy!
    puts "Old configuration destroyed !"
    puts "Linking new configurations to relevant organisations..."
    new_configurations.each do |new_configuration|
      new_configuration.organisations = [organisations.shift]
    end
    raise "Relevant organisations have not all been linked to new configurations" if organisations.present?

    puts "New configurations linked !"
  end
  # Both should be equal to ConfigurationsOrganisation.count from the begining
  puts "#{Configuration.count} configurations and #{ConfigurationsOrganisation.count} configurations_organisations"
  raise "Configurations are not uniq" if Configuration.count != ConfigurationsOrganisation.count

  puts "-------"
  puts "Configurations are all uniq..."

  puts ""
  puts "------------------------------"
  puts ""

  puts "Making messages_configurations uniq..."
  puts "-------"
  MessagesConfiguration.find_each do |messages_configuration|
    puts "Messages configuration #{messages_configuration.id} is linked " \
         "to #{messages_configuration.organisations.length} organisations"
    if messages_configuration.organisations.blank?
      messages_configuration.destroy!
      next
    end

    next if messages_configuration.organisations.length < 2

    puts "Creating new messages_configurations..."
    organisations = messages_configuration.organisations
    organisations.each do |organisation|
      mc = MessagesConfiguration.create!(messages_configuration.attributes.except("id", "created_at", "updated_at"))
      organisation.update!(messages_configuration_id: mc.id)
      puts "New messages_configuration created"
    end
    puts "Destroying old messages_configuration..."
    messages_configuration.destroy!
    puts "Old messages_configuration destroyed !"
  end
  puts "-------"
  puts "Messages_configurations are all uniq..."

  raise "Rolling back after dry run - add COMMIT to commit the transaction!" unless ARGV[0] == "COMMIT"
end
