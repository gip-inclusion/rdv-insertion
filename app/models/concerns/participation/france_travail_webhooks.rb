# For france travail the webhooks are specific, we have to adapt to FT specs as they could not
# implement a system integrating our webhooks, so we separated the two webhooks logic.
module Participation::FranceTravailWebhooks
  extend ActiveSupport::Concern

  included do
    after_commit :handle_france_travail_create_webhook, on: :create, if: -> { eligible_for_france_travail_webhook? }
    after_commit :handle_france_travail_update_webhook, on: :update, if: lambda {
      should_send_france_travail_webhook_on_update?
    }
    before_destroy :handle_france_travail_delete_webhook, if: -> { france_travail_webhook_updatable? }
  end

  def eligible_for_france_travail_webhook?
    eligible_user_for_france_travail_webhook? &&
      eligible_organisation_for_france_travail_webhook? &&
      eligible_department_for_france_travail_webhook?
  end

  def france_travail_webhook_updatable?
    eligible_for_france_travail_webhook? && france_travail_id?
  end

  def france_travail_webhook_newly_eligible?
    eligible_for_france_travail_webhook? && !france_travail_id?
  end

  def should_send_france_travail_webhook_on_update?
    france_travail_webhook_updatable? || france_travail_webhook_newly_eligible?
  end

  private

  def handle_france_travail_create_webhook
    OutgoingWebhooks::FranceTravail::CreateParticipationJob.perform_later(
      participation_id: id, timestamp: created_at
    )
  end

  def handle_france_travail_update_webhook
    if france_travail_webhook_newly_eligible?
      OutgoingWebhooks::FranceTravail::CreateParticipationJob.perform_later(
        participation_id: id, timestamp: updated_at
      )
    else
      OutgoingWebhooks::FranceTravail::UpdateParticipationJob.perform_later(
        participation_id: id, timestamp: updated_at
      )
    end
  end

  def handle_france_travail_delete_webhook
    OutgoingWebhooks::FranceTravail::DeleteParticipationJob.perform_later(
      participation_id: id,
      france_travail_id: france_travail_id,
      user_id: user.id,
      timestamp: Time.current
    )
  end

  def eligible_user_for_france_travail_webhook?
    user.birth_date? && user.nir? && !user.marked_for_rgpd_destruction?
  end

  def eligible_organisation_for_france_travail_webhook?
    # francetravail organisations are not eligible for webhooks, they already have theses rdvs in their own system
    organisation.conseil_departemental? || organisation.delegataire_rsa?
  end

  def eligible_department_for_france_travail_webhook?
    !organisation.department.disable_ft_webhooks?
  end
end
