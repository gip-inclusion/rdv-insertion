module Users
  class SyncWithRdvSolidarites < BaseService
    def initialize(user:, organisation:, rdv_solidarites_session:)
      @user = user
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      User.transaction do
        upsert_rdv_solidarites_user
        if @user.rdv_solidarites_user_id.nil?
          assign_rdv_solidarites_user_id
          save_record!(@user)
        end
      end
    end

    private

    def upsert_rdv_solidarites_user
      @upsert_rdv_solidarites_user ||= call_service!(
        UpsertRdvSolidaritesUser,
        user: @user,
        organisation: @organisation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def assign_rdv_solidarites_user_id
      @user.rdv_solidarites_user_id = upsert_rdv_solidarites_user.rdv_solidarites_user_id
    end
  end
end
