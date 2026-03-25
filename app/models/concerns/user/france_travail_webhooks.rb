module User::FranceTravailWebhooks
  extend ActiveSupport::Concern

  included do
    after_commit :send_pending_participations_to_france_travail, on: :update,
                                                                 if: :became_retrievable_in_france_travail?
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

  def became_retrievable_in_france_travail?
    retrievable_in_france_travail? &&
      (saved_change_to_nir? || saved_change_to_france_travail_id? || saved_change_to_birth_date?)
  end

  def send_pending_participations_to_france_travail
    participations.where(france_travail_id: nil).find_each do |participation|
      next unless participation.eligible_for_france_travail_webhook?

      participation.send_update_to_france_travail_if_eligible(Time.current)
    end
  end
end
