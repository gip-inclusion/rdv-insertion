class MotifCategoryPolicy < ApplicationPolicy
  RSA_RELATED_TYPES = %w[rsa_orientation rsa_accompagnement].freeze

  def self.authorized_for_organisation(organisation)
    if organisation.rsa_related?
      MotifCategory.where(motif_category_type: RSA_RELATED_TYPES)
    else
      MotifCategory.where(motif_category_type: organisation.organisation_type)
    end
  end

  # We need a dedicated method on top of the class method because we may be validating on a new object
  # which the scope is not yet aware of
  def authorized_for_organisation?(organisation)
    return RSA_RELATED_TYPES.include?(record.motif_category_type) if organisation.rsa_related?

    organisation.organisation_type == record.motif_category_type
  end
end
