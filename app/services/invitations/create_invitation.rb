module Invitations
  class CreateInvitation < BaseService
    def initialize(applicant:, rdv_solidarites_session:, invitation_format:)
      @applicant = applicant
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_format = invitation_format
    end

    def call
      if @applicant.invitations.empty?
        retrieve_invitation_token!
        compute_invitation_link!
      else
        @token = @applicant.invitations.last.token
        @link = @applicant.invitations.last.link
      end
      create_invitation!
      result.invitation = @invitation
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
        link: @link,
        token: @token
      )
    end

    def retrieve_invitation_token!
      if retrieve_invitation_token.success?
        @token = retrieve_invitation_token.invitation_token
        return
      end

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
      if compute_invitation_link.success?
        @link = compute_invitation_link.invitation_link
        return
      end

      result.errors += compute_invitation_link.errors
      fail!
    end

    def compute_invitation_link
      @compute_invitation_link ||= Invitations::ComputeLink.call(
        department: department,
        rdv_solidarites_session: @rdv_solidarites_session,
        invitation_token: retrieve_invitation_token.invitation_token
      )
    end

    def rdv_solidarites_user_id
      @applicant.rdv_solidarites_user_id
    end

    def department
      @applicant.department
    end
  end
end
