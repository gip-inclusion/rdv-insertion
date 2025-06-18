# For france travail the webhooks are specific, we have to adapt to FT specs as they could not
# implement a system integrating our webhooks, so we separated the two webhooks logic.
module Participation::FranceTravailWebhooks
  extend ActiveSupport::Concern

  included do
    after_commit :send_france_travail_upsert_webhook, on: [:create, :update], if: :eligible_for_france_travail_webhook?
    before_destroy :send_france_travail_delete_webhook, if: :france_travail_webhook_updatable?
  end

  def eligible_for_france_travail_webhook?
    eligible_user_for_france_travail_webhook? &&
      eligible_organisation_for_france_travail_webhook? &&
      eligible_department_for_france_travail_webhook?
  end

  def france_travail_webhook_updatable?
    eligible_for_france_travail_webhook? && france_travail_id?
  end

  private

  def send_france_travail_upsert_webhook
    OutgoingWebhooks::FranceTravail::UpsertParticipationJob.perform_later(
      participation_id: id,
      timestamp: france_travail_id? ? updated_at : created_at
    )
  end

  def send_france_travail_delete_webhook
    OutgoingWebhooks::FranceTravail::DeleteParticipationJob.perform_later(
      participation_id: id,
      france_travail_id: france_travail_id,
      user_id: user.id,
      timestamp: Time.current
    )
  end

  def eligible_user_for_france_travail_webhook?
    (user_has_a_valid_nir? || user_has_a_valid_france_travail_id?) && !user.marked_for_rgpd_destruction?
  end

  def user_has_a_valid_france_travail_id?
    return false if user.france_travail_id.blank?

    # Valid France Travail ID is exactly 11 digits
    user.france_travail_id.match?(/\A\d{11}\z/)
  end

  def user_has_a_valid_nir?
    user.birth_date? && user.nir?
  end

  def eligible_organisation_for_france_travail_webhook?
    # francetravail organisations are not eligible for webhooks, they already have theses rdvs in their own system
    organisation.conseil_departemental? || organisation.delegataire_rsa?
  end

  def eligible_department_for_france_travail_webhook?
    !organisation.department.disable_ft_webhooks?
  end
end
