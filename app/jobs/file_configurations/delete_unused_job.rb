class FileConfigurations::DeleteUnusedJob < ApplicationJob
  queue_as :default

  def perform
    FileConfiguration.where.missing(:category_configurations).destroy_all
  end
end
