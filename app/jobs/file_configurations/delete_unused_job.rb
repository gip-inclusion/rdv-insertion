class FileConfigurations::DeleteUnusedJob < ApplicationJob
  def perform
    FileConfiguration.where.missing(:category_configurations).destroy_all
  end
end
