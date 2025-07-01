module Users
  class Upsert < BaseService
    def initialize(user_attributes:, organisation:)
      @user_attributes = user_attributes.compact_blank
      @organisation = organisation
    end

    def call
      @user = find_or_initialize_user.user
      result.user = @user
      filter_origin_attributes if @user.persisted?

      # Convert tags_to_add to tag_users_attributes to avoid transaction issues
      # This bypasses the need for organisation_ids in User::Tags#find_tag_in_organisations
      # and reuses the existing tag_users_attributes= method which works with tag IDs directly
      convert_tags_to_add_to_tag_users_attributes

      @user.assign_attributes(@user_attributes.except(*restricted_user_attributes))
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

    def restricted_user_attributes
      UserPolicy.restricted_user_attributes_for(
        user: @user, agent: Current.agent, assigning_organisation: @organisation
      )
    end

    def filter_origin_attributes
      @user_attributes.except!(*User::ORIGIN_ATTRIBUTES)
    end

    def convert_tags_to_add_to_tag_users_attributes
      return if @user_attributes[:tags_to_add].blank?

      tag_values = @user_attributes[:tags_to_add].pluck(:value)
      tag_ids = @organisation.tags.where(value: tag_values).pluck(:id)

      @user_attributes[:tag_users_attributes] = tag_ids.map { |tag_id| { tag_id: tag_id } }
      @user_attributes.delete(:tags_to_add)
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
