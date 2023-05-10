class Archiving < ApplicationRecord
  belongs_to :applicant
  belongs_to :department

  validates :applicant, uniqueness: { scope: :department }

  after_save :invalidate_related_invitations

  private

  def invalidate_related_invitations
    applicant.invitations.where(department: department).find_each do |invitation|
      InvalidateInvitationJob.perform_async(invitation.id)
    end
  end
end
