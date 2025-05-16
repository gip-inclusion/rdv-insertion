module Users
  class PartitionAllUsersJob < ApplicationJob
    queue_as :default

    def perform
      User.select(:id).find_each do |user|
        PartitionSingleUserJob.perform_later(user.id)
      end
    end
  end
end
