class InvalidateInvitationsAfterArchivingJob < ApplicationJob
  def perform(archive_id)
    @archive = Archive.find_by(id: archive_id)
    return unless archive

    related_invitations.find_each do |invitation|
      next unless user_archived_in_all_invitations_organisations?(invitation)

      ExpireInvitationJob.perform_later(invitation.id)
    end
  end

  private

  attr_reader :archive

  def user = archive.user
  def organisation = archive.organisation

  def related_invitations
    organisation.invitations.where(user:)
  end

  def user_archived_in_all_invitations_organisations?(invitation)
    (invitation.organisations & user.organisations).all? do |org|
      user.archived_in_organisation?(org)
    end
  end
end
