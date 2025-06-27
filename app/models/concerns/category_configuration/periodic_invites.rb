module CategoryConfiguration::PeriodicInvites
  extend ActiveSupport::Concern

  MINIMUM_DAYS_BETWEEN_PERIODIC_INVITES = 13
  MAXIMUM_DAYS_BETWEEN_PERIODIC_INVITES = 45

  included do
    validate :periodic_invites_can_be_activated
    validates :number_of_days_between_periodic_invites,
              numericality: { only_integer: true, greater_than: MINIMUM_DAYS_BETWEEN_PERIODIC_INVITES,
                              less_than: MAXIMUM_DAYS_BETWEEN_PERIODIC_INVITES },
              allow_nil: true
  end

  class_methods do
    def time_range_for_candidates_for_periodic_invite
      MAXIMUM_DAYS_BETWEEN_PERIODIC_INVITES.days.ago...MINIMUM_DAYS_BETWEEN_PERIODIC_INVITES.days.ago
    end
  end

  def periodic_invites_activated?
    day_of_the_month_periodic_invites.present? || number_of_days_between_periodic_invites.present?
  end

  def periodic_invite_should_be_sent?(last_invitation_sent_at)
    day_of_the_month_periodic_invites_is_today? ||
      number_of_days_between_periodic_invites_reached_today?(last_invitation_sent_at)
  end

  private

  def day_of_the_month_periodic_invites_is_today?
    day_of_the_month_periodic_invites.present? && Time.zone.today.day == day_of_the_month_periodic_invites
  end

  def number_of_days_between_periodic_invites_reached_today?(last_invitation_sent_at)
    number_of_days_between_periodic_invites.present? &&
      (Time.zone.today - last_invitation_sent_at.to_date).to_i == number_of_days_between_periodic_invites
  end

  def periodic_invites_can_be_activated
    return unless periodic_invites_activated? && invitations_expire?

    errors.add(:base, "Les invitations périodiques ne peuvent pas être activées si " \
                      "les liens des invitations ont une durée de validitée définie. " \
                      "Veuillez retirer la limite de durée de validité des liens d'invitation, " \
                      "ou désactiver les invitations périodiques.")
  end
end
