class UserPolicy < ApplicationPolicy
  RESTRICTED_USER_ATTRIBUTES_BY_ORGANISATION_TYPE = {
    conseil_departemental: [],
    france_travail: [],
    delegataire_rsa: [:nir],
    siae: [:nir, :department_internal_id],
    autre: [:nir, :department_internal_id]
  }.freeze

  def self.restricted_user_attributes_for(user:, agent: Current.agent, assigning_organisation: nil)
    common_organisations = Set.new(user.organisations & agent.organisations)
    if assigning_organisation && agent.organisations.include?(assigning_organisation)
      common_organisations << assigning_organisation
    end
    organisation_types = common_organisations.map(&:organisation_type).map(&:to_sym).uniq
    RESTRICTED_USER_ATTRIBUTES_BY_ORGANISATION_TYPE.slice(*organisation_types).values.min_by(&:length)
  end

  def self.restricted_user_attributes_for_organisations(organisations:)
    organisation_types = organisations.map(&:organisation_type).map(&:to_sym).uniq
    RESTRICTED_USER_ATTRIBUTES_BY_ORGANISATION_TYPE.slice(*organisation_types).values.min_by(&:length)
  end

  def self.show_user_attribute?(user:, attribute_name:, agent: Current.agent)
    restricted_user_attributes_for(user:, agent:).exclude?(attribute_name.to_sym)
  end

  def self.assignable_user_attribute?(user:, attribute_name:, assigning_organisation:, agent: Current.agent)
    restricted_user_attributes_for(user:, agent:, assigning_organisation:).exclude?(attribute_name.to_sym)
  end

  def self.show_user_attribute_for_organisation_type?(attribute_name:, organisation_type:)
    RESTRICTED_USER_ATTRIBUTES_BY_ORGANISATION_TYPE[organisation_type.to_sym].exclude?(attribute_name)
  end

  def new?
    true
  end

  def show?
    pundit_user.organisation_ids.intersect?(record.organisation_ids) && !record.deleted?
  end

  def update?
    show?
  end

  def edit?
    show?
  end

  class Scope < Scope
    def resolve
      scope.joins(:organisations).where(organisations: pundit_user.organisations)
    end
  end
end
