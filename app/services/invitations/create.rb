module Invitations
  class Create < BaseService
    def initialize(applicant:, department:, rdv_solidarites_session:, invitation_format:)
      @applicant = applicant
      @department = department
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_format = invitation_format
    end

    def call
      retrieve_invitation_token! unless existing_token
      compute_invitation_link! unless existing_link
      create_invitation!
      result.invitation = invitation
    end

    private

    def create_invitation!
      return if invitation.save

      result.errors << invitation.errors.full_messages.to_sentence
      fail!
    end

    def invitation
      @invitation ||= Invitation.new(
        applicant: @applicant, format: @invitation_format,
        department: @department,
        link: link, token: token
      )
    end

    def token
      existing_token || retrieve_invitation_token.invitation_token
    end

    def link
      existing_link || compute_invitation_link.invitation_link
    end

    def existing_token
      @applicant.invitations.last&.token
    end

    def existing_link
      @applicant.invitations.last&.link
    end

    def retrieve_invitation_token!
      return if retrieve_invitation_token.success?

      result.errors += retrieve_invitation_token.errors
      fail!
    end

    def retrieve_invitation_token
      @retrieve_invitation_token ||= Invitations::RetrieveToken.call(
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_user_id: rdv_solidarites_user_id
      )
    end

    def compute_invitation_link!
      return if compute_invitation_link.success?

      result.errors += compute_invitation_link.errors
      fail!
    end

    def compute_invitation_link
      @compute_invitation_link ||= Invitations::ComputeLink.call(
        department: @department,
        rdv_solidarites_session: @rdv_solidarites_session,
        invitation_token: retrieve_invitation_token.invitation_token
      )
    end

    def rdv_solidarites_user_id
      @applicant.rdv_solidarites_user_id
    end
  end
end
