class Archive < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user, uniqueness: { scope: :organisation }

  after_create :invalidate_related_invitations

  private

  def invalidate_related_invitations
    organisation.invitations.where(id: user.invitations.pluck(:id)).includes(:organisations).find_each do |invitation|
      if invitation.organisations.count > 1
        invitation.organisations.delete(organisation)
      else
        InvalidateInvitationJob.perform_async(invitation.id)
      end
    end
  end
end
