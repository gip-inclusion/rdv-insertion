# For france travail the webhooks are specific, we have to adapt to FT specs as they could not
# implement a system integrating our webhooks, so we separated the two webhooks logic.
module Participation::FranceTravailWebhooks
  extend ActiveSupport::Concern

  included do
    after_commit on: :create, if: -> { eligible_for_france_travail_webhook? } do
      OutgoingWebhooks::FranceTravail::CreateParticipationJob.perform_later(
        participation_id: id, timestamp: created_at
      )
    end

    after_commit on: :update, if: -> { france_travail_webhook_updatable? } do
      OutgoingWebhooks::FranceTravail::UpdateParticipationJob.perform_later(
        participation_id: id, timestamp: updated_at
      )
    end

    before_destroy do
      if france_travail_webhook_updatable?
        OutgoingWebhooks::FranceTravail::DeleteParticipationJob.perform_later(
          participation_id: id,
          france_travail_id: france_travail_id,
          user_id: user.id,
          timestamp: Time.current
        )
      end
    end
  end

  def eligible_for_france_travail_webhook?
    eligible_organisation? && user.birth_date? && user.nir? && france_travail_active_department?
  end

  def france_travail_webhook_updatable?
    eligible_for_france_travail_webhook? && france_travail_id?
  end

  def france_travail_active_department?
    # C'est une condition temporaire le temps de tester la fonctionnalité en production sur un département
    organisation.department.number.in?(ENV.fetch("FRANCE_TRAVAIL_WEBHOOKS_DEPARTMENTS", "").split(","))
  end

  def eligible_organisation?
    # francetravail organisations are not eligible for webhooks, they already have theses rdvs in their own system
    organisation.delegataire_rsa? || organisation.conseil_departemental?
  end
end
