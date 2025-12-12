class CategoryConfigurationPolicy < ApplicationPolicy
  def show?
    # used in /file_configurations/_select_item.html.erb
    pundit_user.organisation_ids.include?(record.organisation_id)
  end

  def edit_rdv_preferences? = admin_of_organisation?
  def update_rdv_preferences? = admin_of_organisation?
  def edit_messages? = admin_of_organisation?
  def update_messages? = admin_of_organisation?
  def edit_notifications? = admin_of_organisation?
  def update_notifications? = admin_of_organisation?
  def edit_file_import? = admin_of_organisation?
  def update_file_import? = admin_of_organisation?

  class Scope < Scope
    def resolve
      scope.where(organisation_id: pundit_user.organisation_ids)
    end
  end

  private

  def admin_of_organisation?
    record.organisation_id.in?(pundit_user.admin_organisations_ids)
  end
end
