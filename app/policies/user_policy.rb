class UserPolicy < ApplicationPolicy
  def self.authorized_user_attributes_by_organisation_type = {
    conseil_departemental: User.symbolized_attribute_names,
    france_travail: User.symbolized_attribute_names,
    delegataire_rsa: User.symbolized_attribute_names - [:nir],
    siae: User.symbolized_attribute_names - [:nir, :department_internal_id],
    autre: User.symbolized_attribute_names - [:nir, :department_internal_id]
  }

  def self.authorized_user_attributes_for(user:, agent: Current.agent, organisation_to_be_assigned: nil)
    common_organisations = Set.new(user.organisations & agent.organisations)
    if organisation_to_be_assigned && agent.organisations.include?(organisation_to_be_assigned)
      common_organisations << organisation_to_be_assigned
    end
    organisation_types = common_organisations.map(&:organisation_type).map(&:to_sym).uniq
    authorized_user_attributes_by_organisation_type.slice(*organisation_types).values.max_by(&:length)
  end

  def self.show_user_attribute?(user:, attribute_name:, agent: Current.agent)
    authorized_user_attributes_for(user:, agent:).include?(attribute_name.to_sym)
  end

  def self.assignable_user_attribute?(user:, attribute_name:, organisation_to_be_assigned:, agent: Current.agent)
    authorized_user_attributes_for(user:, agent:, organisation_to_be_assigned:).include?(attribute_name.to_sym)
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
