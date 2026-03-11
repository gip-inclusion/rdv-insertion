module Users
  class PartitionAllUsersJob < ApplicationJob
    def perform
      SlackClient.send_to_private_channel(
        "🚀 Démarrage de la partition des usagers par département (#{User.active.count} usagers)"
      )

      User.active.find_each do |user|
        Users::PartitionSingleUserJob.perform_later(user.id)
      end

      SlackClient.send_to_private_channel("✅ #{User.count} jobs de partition enqueués")
    end
  end
end
