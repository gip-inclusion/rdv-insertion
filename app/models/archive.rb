class Archive < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }

  after_create_commit :invalidate_related_invitations

  def self.new_batch(organisation_ids:, user_id:, archiving_reason:)
    organisation_ids.map do |organisation_id|
      new(organisation_id:, user_id:, archiving_reason:)
    end
  end

  private

  def invalidate_related_invitations
    organisation.invitations.where(user: user.reload).includes(:organisations).find_each do |invitation|
      next unless (invitation.organisations & user.organisations).all? do |organisation|
        user.archived_in_organisation?(organisation)
      end

      ExpireInvitationJob.perform_later(invitation.id)
    end
  end
end
