module UserListUpload::UserRow::UserSaveable
  extend ActiveSupport::Concern

  included do
    has_many :user_save_attempts, class_name: "UserListUpload::UserSaveAttempt", dependent: :destroy

    after_commit :enqueue_save_user_job, if: :should_save_user_automatically?, on: :update
  end

  def saved_user
    user_save_attempts.find(&:success?)&.user
  end

  def saved_user_id
    saved_user&.id
  end

  def save_user
    UserListUpload::UserSaveAttempt.create_from_row(user_row: self)
  end

  def attempted_user_save?
    user_save_attempts.any?
  end

  def last_user_save_attempt
    user_save_attempts.max_by(&:created_at)
  end

  def user_save_succeeded?
    last_user_save_attempt&.success?
  end

  private

  def enqueue_save_user_job
    UserListUpload::SaveUserJob.perform_later(id)
  end

  def should_save_user_automatically?
    # automatic saves can only be triggered when a save has been attempted and when we change
    # some attributes
    attempted_user_save? && previous_changes.keys.any? do |attribute|
      (self.class::USER_ATTRIBUTES + [:assigned_organisation_id]).include?(attribute.to_sym)
    end
  end
end
