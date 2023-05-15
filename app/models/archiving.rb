class Archiving < ApplicationRecord
  belongs_to :applicant
  belongs_to :department

  validates :applicant, uniqueness: { scope: :department }

  after_save :invalidate_related_invitations

  delegate :first_name, :last_name,
           :last_invitation_sent_at, :first_invitation_relative_to_last_participation_sent_at,
           to: :applicant, prefix: true

  private

  def invalidate_related_invitations
    applicant.invitations.where(department: department).find_each do |invitation|
      InvalidateInvitationJob.perform_async(invitation.id)
    end
  end
end
