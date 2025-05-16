require Rails.root.join("lib/users/partition_users_by_department")

namespace :users do
  desc <<-DESC
    This task allows to partition users by department
    it only keeps the organisations in the same department as the most recent activity
  DESC
  task partition_users_by_department: :environment do
    Users::PartitionAllUsersJob.perform_later
  end
end
