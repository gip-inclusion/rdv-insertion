class Archive < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }
  validate :user_must_belong_to_organisation

  after_create_commit :invalidate_related_invitations

  def self.new_batch(organisation_ids:, user_id:, archiving_reason:)
    organisation_ids.map do |organisation_id|
      new(organisation_id:, user_id:, archiving_reason:)
    end
  end

  private

  def invalidate_related_invitations
    InvalidateInvitationsAfterArchivingJob.perform_later(id)
  end

  def user_must_belong_to_organisation
    return if user.reload.organisation_ids.include?(organisation_id)

    errors.add(:user_id, "doit appartenir à l'organisation")
  end
end
