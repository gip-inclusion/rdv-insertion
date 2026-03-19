namespace :users do
  desc "Partition tous les usagers par département en leur assignant un department_id"
  task partition_by_department: :environment do
    Users::PartitionAllUsersJob.perform_later
  end
end
