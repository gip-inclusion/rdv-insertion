class MotifCategoryPolicy < ApplicationPolicy
  class Scope
    attr_reader :scope, :organisation

    def initialize(scope, organisation)
      @scope = scope
      @organisation = organisation
    end

    def resolve
      if organisation.rsa_related?
        scope.where(motif_category_type: MotifCategory::RSA_RELATED_TYPES)
      else
        scope.where(motif_category_type: organisation.organisation_type)
      end
    end
  end

  # We need a dedicated method on top of the scope because we may be validating on a new object
  # which the scope is not yet aware of
  def authorized_for_organisation?(organisation)
    return MotifCategory::RSA_RELATED_TYPES.include?(record.motif_category_type) if organisation.rsa_related?

    organisation.organisation_type == record.motif_category_type
  end
end
