module Users
  class Save < BaseService
    def initialize(user:, organisation: nil)
      @user = user
      @organisation = organisation
    end

    def call
      User.transaction do
        assign_organisation if @organisation.present?
        validate_user!
        save_record!(@user)
        sync_with_rdv_solidarites
      end
      result.user = @user
    end

    private

    def assign_organisation
      @user.organisations = (@user.organisations.to_a + [@organisation]).uniq
    end

    def sync_with_rdv_solidarites
      call_service!(
        Users::SyncWithRdvSolidarites,
        user: @user
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
