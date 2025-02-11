module Users
  class PushToRdvSolidarites < BaseService
    def initialize(user:)
      @user = user.reload # we need to be sure the associations are correctly loaded
      @rdv_solidarites_user_id = @user.rdv_solidarites_user_id
    end

    def call
      upsert_rdv_solidarites_user
      assign_rdv_solidarites_user_id! if @user.rdv_solidarites_user_id.nil?
    end

    private

    def email_field
      @email_field ||= begin
        retrieved_user = retrieve_user.user
        if retrieved_user.notification_email.present? || retrieved_user.email.blank?
          # We use notification_email if:
          # - it is already present in the retrieved user
          # - or no email is present (default behavior as in creation)
          :notification_email
        else
          :email
        end
      end
    end

    def retrieve_user
      @retrieve_user ||= call_service!(
        RdvSolidaritesApi::RetrieveUser,
        rdv_solidarites_user_id: @rdv_solidarites_user_id
      )
    end

    def assign_rdv_solidarites_user_id!
      @user.rdv_solidarites_user_id = @rdv_solidarites_user_id
      save_record!(@user)
    end

    def upsert_rdv_solidarites_user
      @rdv_solidarites_user_id.present? ? update_user_and_associations : create_rdv_solidarites_user!
    end

    def update_user_and_associations
      upsert_user_profiles
      upsert_referents if @user.referents.any?
      update_rdv_solidarites_user
    end

    def create_rdv_solidarites_user!
      if create_rdv_solidarites_user.success?
        @rdv_solidarites_user_id = create_rdv_solidarites_user.user.id
        return
      end

      result.errors += create_rdv_solidarites_user.errors
      fail!
    end

    def create_rdv_solidarites_user
      @create_rdv_solidarites_user ||= RdvSolidaritesApi::CreateUser.call(
        user_attributes:
          rdv_solidarites_user_attributes
            .merge(organisation_ids: rdv_solidarites_organisation_ids)
            .merge(referent_agent_ids: referent_rdv_solidarites_ids)
      )
    end

    def upsert_user_profiles
      @upsert_user_profiles ||= call_service!(
        RdvSolidaritesApi::CreateUserProfiles,
        rdv_solidarites_user_id: @rdv_solidarites_user_id,
        rdv_solidarites_organisation_ids: rdv_solidarites_organisation_ids
      )
    end

    def upsert_referents
      @upsert_referents ||= call_service!(
        RdvSolidaritesApi::CreateReferentAssignations,
        rdv_solidarites_user_id: @rdv_solidarites_user_id,
        rdv_solidarites_agent_ids: referent_rdv_solidarites_ids
      )
    end

    def update_rdv_solidarites_user
      @update_rdv_solidarites_user ||= call_service!(
        RdvSolidaritesApi::UpdateUser,
        user_attributes: rdv_solidarites_user_attributes,
        rdv_solidarites_user_id: @rdv_solidarites_user_id
      )
    end

    def rdv_solidarites_user_attributes
      attrs = @user.attributes
                   .symbolize_keys
                   .slice(*User::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
                   .transform_values(&:presence)
                   .compact

      select_appropriate_email_field(attrs)

      attrs
    end

    def select_appropriate_email_field(attrs)
      if @rdv_solidarites_user_id
        # Existing users in RDV-S could have either email or notification_email set
        # Only convert to notification_email if that's the field currently used
        attrs[:notification_email] = attrs.delete(:email) if email_field == :notification_email
      else
        # New users are always created with notification_email in RDV-S
        attrs[:notification_email] = attrs.delete(:email)
      end
    end

    def rdv_solidarites_organisation_ids
      @user.organisations.map(&:rdv_solidarites_organisation_id)
    end

    def referent_rdv_solidarites_ids
      @user.referents.map(&:rdv_solidarites_agent_id)
    end
  end
end
