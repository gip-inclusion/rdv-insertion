module Invitations
  class CreateInvitations < BaseService
    def initialize(applicant:, invitation_format:, link:, token:)
      @applicant = applicant
      @format = invitation_format
      @link = link
      @token = token
    end

    def call
      @invitations = []
      create_invitations
      result.invitations = @invitations
    end

    private

    def create_invitations
      case @format
      when "sms"
        create_invitation!("sms")
      when "email"
        create_invitation!("email")
      when "link_only"
        create_invitation!("link_only")
      when "sms_and_email"
        create_invitation!("sms")
        create_invitation!("email")
      end
    end

    def create_invitation!(invitation_format)
      invitation = invitation(invitation_format)
      if invitation.save
        @invitations << invitation
        return
      end

      result.errors << invitation.errors.full_messages.to_sentence
      fail!
    end

    def invitation(invitation_format)
      Invitation.new(
        applicant: @applicant, format: invitation_format,
        link: @link, token: @token
      )
    end
  end
end
