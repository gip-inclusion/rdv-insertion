module Users
  class PartitionAllUsersJob < ApplicationJob
    def perform
      User.where(department_id: nil).select(:id).find_each do |user|
        PartitionSingleUserJob.perform_later(user.id)
      end
    end
  end
end
