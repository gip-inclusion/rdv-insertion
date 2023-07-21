module Invitations
  class AssignAttributes < BaseService
    def initialize(invitation:, rdv_solidarites_session:)
      @invitation = invitation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      @invitation.rdv_solidarites_token = rdv_solidarites_token
      @invitation.link = invitation_link
    end

    private

    def applicant
      # we reload in case the applicant had a new invitation attached to it after
      # the invitation has been instantiated
      @invitation.applicant.reload
    end

    def rdv_solidarites_token
      same_last_and_rdvs_token? ? last_sent_rdv_solidarites_token : retrieve_rdv_solidarites_token.invitation_token
    end

    def same_last_and_rdvs_token?
      last_sent_rdv_solidarites_token == retrieve_rdv_solidarites_token.invitation_token
    end

    def last_sent_rdv_solidarites_token
      @last_sent_rdv_solidarites_token ||= applicant.last_sent_invitation&.rdv_solidarites_token
    end

    def retrieve_rdv_solidarites_token
      @retrieve_rdv_solidarites_token ||= call_service!(
        RdvSolidaritesApi::CreateOrRetrieveInvitationToken,
        rdv_solidarites_user_id: applicant.rdv_solidarites_user_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def compute_invitation_link
      @compute_invitation_link ||= call_service!(
        Invitations::ComputeLink,
        invitation: @invitation
      )
    end

    def invitation_link
      compute_invitation_link.invitation_link
    end
  end
end
