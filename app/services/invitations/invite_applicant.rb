module Invitations
  class InviteApplicant < BaseService
    def initialize(applicant:, rdv_solidarites_session:, invitation_format:)
      @applicant = applicant
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_format = invitation_format
    end

    def call
      retrieve_or_create_invitation!
      send_invitation!
      update_invitation_sent_at!
      result.invitation = invitation
    end

    private

    def update_invitation_sent_at!
      return if invitation.update(sent_at: Time.zone.now)

      result.errors << invitation.errors.full_messages.to_sentence
      fail!
    end

    def send_invitation!
      return if send_invitation.success?

      result.errors += send_invitation.errors
      fail!
    end

    def send_invitation
      @send_invitation ||= invitation.send_to_applicant
    end

    def invitation
      retrieve_or_create_invitation.invitation
    end

    def retrieve_or_create_invitation!
      return if retrieve_or_create_invitation.success?

      result.errors += retrieve_or_create_invitation.errors
      fail!
    end

    def retrieve_or_create_invitation
      @retrieve_or_create_invitation ||= Invitations::RetrieveOrCreateInvitation.call(
        applicant: @applicant, invitation_format: @invitation_format,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
