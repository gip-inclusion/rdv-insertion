class InviteUserJob < ApplicationJob
  sidekiq_options retry: 10

  def perform(user_id, organisation_id, invitation_attributes, motif_category_attributes)
    @user = User.find(user_id)
    @organisation = Organisation.find(organisation_id)
    @invitation_attributes = invitation_attributes.deep_symbolize_keys
    @motif_category_attributes = motif_category_attributes

    Invitation.with_advisory_lock "invite_user_job_#{@user.id}" do
      invite_user!
    end
  end

  private

  def invite_user!
    invite_user_service = InviteUser.call(
      user: @user,
      organisations: [@organisation],
      invitation_attributes: @invitation_attributes,
      motif_category_attributes: @motif_category_attributes,
      check_creneaux_availability: false
    )
    return if invite_user_service.success?

    raise(
      FailedServiceError,
      "Could not send invitation to user #{@user.id} in InviteUserJob: " \
      "#{invite_user_service.errors}"
    )
  end
end
