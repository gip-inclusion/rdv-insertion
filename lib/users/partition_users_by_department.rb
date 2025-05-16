module Users
  class PartitionUsersByDepartment
    def call
      PartitionAllUsersJob.perform_later
    end
  end
end
