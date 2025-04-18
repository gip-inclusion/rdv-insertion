class CreneauAvailability < ApplicationRecord
  include NotificationCenter::CreneauxAvailabilityAsNotification

  belongs_to :category_configuration

  scope :with_pending_invitations, lambda {
    where.not(number_of_pending_invitations: [nil, 0])
  }

  def availability_level
    return "info" if number_of_creneaux_available > 190

    diff = number_of_creneaux_available - number_of_pending_invitations

    if diff.negative?
      "danger"
    elsif diff < 10
      "warning"
    else
      "info"
    end
  end

  def low_availability?
    %w[danger warning].include?(availability_level)
  end
end
