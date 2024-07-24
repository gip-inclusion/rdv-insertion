module Users
  class Upsert < BaseService
    def initialize(user_attributes:, organisation:)
      @user_attributes = user_attributes.compact_blank
      @organisation = organisation
    end

    def call
      @user = find_or_initialize_user.user
      result.user = @user
      @user.assign_authorized_attributes(@user_attributes, authorized_user_attributes)
      save_user!
    end

    private

    def find_or_initialize_user
      @find_or_initialize_user ||= call_service!(
        Users::FindOrInitialize,
        attributes: @user_attributes,
        department_id: @organisation.department_id
      )
    end

    def authorized_user_attributes
      UserPolicy.authorized_user_attributes_for(
        user: @user, agent: Current.agent, organisation_to_be_assigned: @organisation
      )
    end

    def save_user!
      call_service!(
        Users::Save,
        user: @user,
        organisation: @organisation
      )
    end
  end
end
