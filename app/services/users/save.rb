module Users
  class Save < BaseService
    def initialize(user:, organisation: nil)
      @user = user
      @organisation = organisation
    end

    def call
      save_user
      result.user = @user
    end

    private

    def save_user
      User.with_advisory_lock "saving_user_#{lock_key}" do
        User.transaction do
          assign_organisation if @organisation.present?
          validate_user!
          deduplicate_tag_users_attributes
          save_record!(@user)
          push_user_to_rdv_solidarites
        end
      end
    end

    def lock_key
      @user.to_s.presence || SecureRandom.uuid
    end

    def assign_organisation
      @user.organisations = (@user.organisations.to_a + [@organisation]).uniq
    end

    def push_user_to_rdv_solidarites
      call_service!(Users::PushToRdvSolidarites, user: @user)
    end

    def validate_user!
      call_service!(Users::Validate, user: @user)
    end

    def deduplicate_tag_users_attributes
      @user.tag_users = @user.tag_users.uniq(&:tag_id)
    end
  end
end
