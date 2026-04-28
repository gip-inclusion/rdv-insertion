module OutgoingWebhooks
  module FranceTravail
    class SendPendingParticipationsJob < ApplicationJob
      def perform(user_id:)
        user = User.find(user_id)

        user.participations.where(france_travail_id: nil).find_each do |participation|
          next unless participation.eligible_for_france_travail_webhook?

          participation.send_update_to_france_travail_if_eligible
        end
      end
    end
  end
end
