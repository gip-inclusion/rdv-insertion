module Users
  class Save < BaseService
    def initialize(user:, organisation:, rdv_solidarites_session:)
      @user = user
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      User.transaction do
        assign_organisation
        validate_user!
        save_record!(@user)
        upsert_rdv_solidarites_user
      end
      result.user = @user
    end

    private

    def assign_organisation
      @user.organisations = (@user.organisations.to_a + [@organisation]).uniq
    end

    def upsert_rdv_solidarites_user
      call_service!(
        UpsertRdvSolidaritesUser,
        user: @user,
        organisation: @organisation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def validate_user!
      call_service!(
        Users::Validate,
        user: @user
      )
    end
  end
end
