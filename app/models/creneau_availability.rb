class CreneauAvailability < ApplicationRecord
  belongs_to :category_configuration

  scope :with_pending_invitations, lambda {
    where.not(number_of_pending_invitations: [nil, 0])
  }

  scope :lacking_availability, lambda {
    with_pending_invitations
      .where(
        "(number_of_creneaux_available <= number_of_pending_invitations) OR " \
        "(number_of_creneaux_available - number_of_pending_invitations < 10)"
      )
  }

  def seriousness
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
end
