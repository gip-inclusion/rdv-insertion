class InviteUserJob < ApplicationJob
  include LockedJobs

  sidekiq_options retry: 10

  def self.lock_key(user_id, _organisation_id, _invitation_attributes, _motif_category_attributes)
    "#{name}:#{user_id}"
  end

  def perform(user_id, organisation_id, invitation_attributes, motif_category_attributes)
    @user = User.find(user_id)
    @organisation = Organisation.find(organisation_id)
    @invitation_attributes = invitation_attributes.deep_symbolize_keys
    @motif_category_attributes = motif_category_attributes

    invite_user!
  end

  private

  def invite_user!
    call_service!(
      InviteUser,
      user: @user,
      organisations: [@organisation],
      invitation_attributes: @invitation_attributes,
      motif_category_attributes: @motif_category_attributes,
      check_creneaux_availability: false
    )
  end
end
