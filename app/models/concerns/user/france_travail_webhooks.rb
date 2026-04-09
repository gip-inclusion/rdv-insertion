module User::FranceTravailWebhooks
  extend ActiveSupport::Concern

  included do
    after_commit :send_pending_participations_to_france_travail, on: :update,
                                                                 if: :retrievable_in_france_travail_and_attributes_changed?
  end

  def retrievable_in_france_travail?
    nir_and_birth_date? || valid_france_travail_id?
  end

  def valid_france_travail_id?
    france_travail_id? && france_travail_id.match?(/\A\d{11}\z/)
  end

  def nir_and_birth_date?
    birth_date? && nir?
  end

  private

  def retrievable_in_france_travail_and_attributes_changed?
    retrievable_in_france_travail? &&
      (saved_change_to_nir? || saved_change_to_france_travail_id? || saved_change_to_birth_date?)
  end

  def send_pending_participations_to_france_travail
    OutgoingWebhooks::FranceTravail::SendPendingParticipationsJob.perform_later(user_id: id)
  end
end
