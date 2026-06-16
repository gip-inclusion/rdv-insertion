class CategoryConfiguration::CreneauAvailability < ApplicationRecord
  include Creneaux::AvailabilityPeriod

  self.table_name = "category_configuration_creneau_availabilities"

  belongs_to :category_configuration

  scope :with_pending_invitations, lambda {
    where.not(number_of_pending_invitations: [nil, 0])
  }

  scope :with_rsa_related_motif, lambda {
    joins(category_configuration: :motif_category)
      .where(category_configuration: {
               motif_categories: {
                 motif_category_type: MotifCategory::RSA_RELATED_TYPES
               }
             })
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

  def motifs_with_public_creneaux
    Motif.active.bookable_by_everyone_or_invited_users.without_referents
         .where(motif_category: category_configuration.motif_category,
                organisation: category_configuration.organisation)
  end
end
