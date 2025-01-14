class MotifCategoryPolicy < ApplicationPolicy
  def self.authorized_for_organisation(organisation)
    if organisation.rsa_related?
      MotifCategory.where(motif_category_type: MotifCategory::RSA_RELATED_TYPES)
    else
      MotifCategory.where(motif_category_type: organisation.organisation_type)
    end
  end

  def self.authorized_for_organisation?(motif_category, organisation)
    return MotifCategory::RSA_RELATED_TYPES.include?(motif_category.motif_category_type) if organisation.rsa_related?

    organisation.organisation_type == motif_category.motif_category_type
  end
end
