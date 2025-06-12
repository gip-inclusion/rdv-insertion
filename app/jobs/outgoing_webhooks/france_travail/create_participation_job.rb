module OutgoingWebhooks
  module FranceTravail
    class CreateParticipationJob < BaseJob
      def perform(participation_id:, timestamp:)
        participation = Participation.find_by(id: participation_id)

        return unless participation

        call_service!(FranceTravailApi::CreateParticipation, participation:, timestamp:)
      end
    end
  end
end
