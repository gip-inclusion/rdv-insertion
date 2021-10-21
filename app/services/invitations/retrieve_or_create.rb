module Invitations
  class RetrieveOrCreate < BaseService
    def initialize(applicant:, department:, rdv_solidarites_session:, invitation_format:)
      @applicant = applicant
      @department = department
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_format = invitation_format
    end

    def call
      create_invitation! unless existing_invitation
      result.invitation = invitation
    end

    private

    def invitation
      existing_invitation || create_invitation.invitation
    end

    def existing_invitation
      @applicant.invitations.find_by(format: @invitation_format, department: @department)
    end

    def create_invitation!
      return if create_invitation.success?

      result.errors += create_invitation.errors
      fail!
    end

    def create_invitation
      @create_invitation ||= Invitations::Create.call(
        applicant: @applicant, invitation_format: @invitation_format,
        department: @department,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
