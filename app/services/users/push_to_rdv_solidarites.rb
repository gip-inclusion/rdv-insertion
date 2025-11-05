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

    def email_field_to_target
      @email_field_to_target ||= begin
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
      @rdv_solidarites_user_id.present? ? update_user_and_associations : handle_user_creation
    end

    def update_user_and_associations
      # upserting associations is useful when adding orgs or referents to an existing user
      # from user list uploads for example
      upsert_user_profiles
      upsert_referents if @user.referents.any?
      update_rdv_solidarites_user
    end

    def handle_user_creation
      create_rdv_solidarites_user!
      # if user already existed in rdv-insertion (and rdv_solidarites_user_id has been nullified),
      # we need to push its associations in rdv-solidarites.
      # we already push the organisations common to the agent and the user during the rdv_solidarites_user creation
      upsert_user_profiles if user_in_organisations_agent_does_not_belong_to?
      upsert_referents if @user.referents.any?
    end

    def create_rdv_solidarites_user!
      fail!("Aucune organisation assignée à l'usager") if @user.organisations.empty?

      if create_rdv_solidarites_user.success?
        @rdv_solidarites_user_id = create_rdv_solidarites_user.user.id
        return
      end

      result.errors += create_rdv_solidarites_user.errors
      fail!
    end

    def create_rdv_solidarites_user
      @create_rdv_solidarites_user ||= RdvSolidaritesApi::CreateUser.call(
        user_attributes: rdv_solidarites_user_attributes.merge(
          organisation_ids: user_agent_rdv_solidarites_organisation_ids
        )
      )
    end

    def upsert_user_profiles
      @upsert_user_profiles ||= call_service!(
        RdvSolidaritesApi::CreateUserProfiles,
        rdv_solidarites_user_id: @rdv_solidarites_user_id,
        rdv_solidarites_organisation_ids: user_rdv_solidarites_organisation_ids
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

      attrs[:notification_email] = attrs.delete(:email) if should_target_notification_email?

      attrs
    end

    def should_target_notification_email?
      @rdv_solidarites_user_id.nil? || email_field_to_target == :notification_email
    end

    def user_rdv_solidarites_organisation_ids
      @user.organisations.map(&:rdv_solidarites_organisation_id)
    end

    def referent_rdv_solidarites_ids
      @user.referents.map(&:rdv_solidarites_agent_id)
    end

    def user_agent_rdv_solidarites_organisation_ids
      (@user.organisations & Current.agent.organisations).map(&:rdv_solidarites_organisation_id)
    end

    def user_in_organisations_agent_does_not_belong_to?
      user_rdv_solidarites_organisation_ids.length > user_agent_rdv_solidarites_organisation_ids.length
    end
  end
end
