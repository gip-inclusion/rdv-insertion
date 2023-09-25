class Archive < ApplicationRecord
  belongs_to :user
  belongs_to :department

  validates :user, uniqueness: { scope: :department }

  after_save :invalidate_related_invitations

  private

  def invalidate_related_invitations
    user.invitations.where(department: department).find_each do |invitation|
      InvalidateInvitationJob.perform_async(invitation.id)
    end
  end
end
