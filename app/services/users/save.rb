module Users
  class Save < BaseService
    def initialize(user:, organisation:, rdv_solidarites_session:)
      @user = user
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      result.user = @user
      User.transaction do
        assign_organisation
        validate_user!
        save_record!(@user)
        upsert_rdv_solidarites_user
        assign_rdv_solidarites_user_id unless @user.rdv_solidarites_user_id?
      end
    end

    private

    def assign_organisation
      @user.organisations = (@user.organisations.to_a + [@organisation]).uniq
    end

    def upsert_rdv_solidarites_user
      @upsert_rdv_solidarites_user ||= call_service!(
        UpsertRdvSolidaritesUser,
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_user_attributes: rdv_solidarites_user_attributes,
        rdv_solidarites_user_id: @user.rdv_solidarites_user_id
      )
    end

    def validate_user!
      call_service!(
        Users::Validate,
        user: @user
      )
    end

    def assign_rdv_solidarites_user_id
      @user.rdv_solidarites_user_id = upsert_rdv_solidarites_user.rdv_solidarites_user_id
      save_record!(@user)
    end

    def rdv_solidarites_user_attributes
      user_attributes = @user.attributes
                             .symbolize_keys
                             .slice(*User::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
                             .transform_values(&:presence)
                             .compact
      user_attributes.delete(:email) if @user.conjoint?
      user_attributes
    end
  end
end
