class Archive < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  attr_accessor :skip_after_create

  validates :user_id, uniqueness: { scope: :organisation_id }

  after_create :invalidate_related_invitations

  def self.new_batch(organisation_ids:, user_id:, archiving_reason:)
    organisation_ids.map do |organisation_id|
      new(organisation_id:, user_id:, archiving_reason:)
    end
  end

  private

  def invalidate_related_invitations
    return if skip_after_create

    organisation.invitations.where(user_id: user.id).includes(:organisations).find_each do |invitation|
      invitation_archives = Archive.where(organisation_id: invitation.organisations, user_id: user.id)
      if invitation_archives.count == invitation.organisations.count
        InvalidateInvitationJob.perform_async(invitation.id)
      end
    end
  end
end
