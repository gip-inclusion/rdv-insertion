module Invitations
  class InviteApplicant < BaseService
    def initialize(applicant:, organisation:, rdv_solidarites_session:, invitation_format:)
      @applicant = applicant
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_format = invitation_format
    end

    def call
      check_applicant_organisation!
      retrieve_or_create_invitation!
      send_invitation!
      update_invitation_sent_at!
      result.invitation = invitation
    end

    private

    def check_applicant_organisation!
      return if @applicant.organisation_ids.include?(@organisation.id)

      fail!("l'allocataire ne peut être invité car il n'appartient pas à l'organisation.")
    end

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
      @retrieve_or_create_invitation ||= Invitations::RetrieveOrCreate.call(
        applicant: @applicant, invitation_format: @invitation_format,
        organisation: @organisation,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
