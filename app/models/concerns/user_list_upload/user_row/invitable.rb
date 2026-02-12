module UserListUpload::UserRow::Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitation_attempts, class_name: "UserListUpload::InvitationAttempt", dependent: :destroy
  end

  def invitable?
    user.persisted? && user.can_be_invited_through_phone_or_email? && !invited_less_than_24_hours_ago?
  end

  def invite_user_by(format)
    UserListUpload::InvitationAttempt.create_from_row(user_row: self, format:)
  end

  def invite_user
    invite_user_by("email") if can_be_invited_through?("email")
    invite_user_by("sms") if can_be_invited_through?("sms")
  end

  def invitation_attempted?
    invitation_attempts.any?
  end

  def last_invitation_attempt
    invitation_attempts.max_by(&:created_at)
  end

  def invitation_errors
    invitation_attempts.flat_map(&:service_errors)
  end

  def all_invitations_failed?
    invitation_attempted? && invitation_attempts.none?(&:success?)
  end

  def invitation_succeeded?
    invitation_attempts.any?(&:success?)
  end

  def previously_invited?
    previous_invitations.any?
  end

  def previously_invited_at
    previous_invitations.max_by(&:created_at).created_at
  end

  def invited_less_than_24_hours_ago?
    previously_invited? && previously_invited_at > 24.hours.ago
  end

  private

  def previous_invitations
    @previous_invitations ||= user.invitations.select do |invitation|
      # we don't consider the user as invited here if the invitation has not been sent by email or sms
      invitation.format.in?(%w[email sms]) &&
        invitation.motif_category_id == user_list_upload.motif_category_id &&
        !invitation.delivery_failed?
    end
  end
end
