# For france travail the webhooks are specific, we have to adapt to FT specs as they could not
# implement a system integrating our webhooks, so we separated the two webhooks logic.
module Participation::FranceTravailWebhooks
  extend ActiveSupport::Concern

  included do
    after_commit on: :create, if: -> { organisation.france_travail? } do
      OutgoingWebhooks::FranceTravail::ProcessParticipationJob.perform_later(
        participation_id: id, timestamp: created_at, event: :create
      )
    end

    after_commit on: :update, if: -> { organisation.france_travail? } do
      OutgoingWebhooks::FranceTravail::ProcessParticipationJob.perform_later(
        participation_id: id, timestamp: updated_at, event: :update
      )
    end

    around_destroy lambda { |participation, block|
      if participation.organisation.france_travail?
        OutgoingWebhooks::FranceTravail::ProcessParticipationJob.perform_later(
          participation_id: participation.id, timestamp: Time.current, event: :delete
        )
      end

      block.call
    }
  end
end