module Invitations
  class Send < BaseService
    def initialize(invitation:, rdv_solidarites_user:)
      @invitation = invitation
      # rdv solidarites user is needed to get the phone number and email
      # TODO: check if we cannot store them ourselves when creating the applicant
      @rdv_solidarites_user = rdv_solidarites_user
    end

    def call
      case invitation_format
      when "sms"
        Invitations::SendSms.call(invitation: @invitation, phone_number: phone_number_formatted)
      when "email"
        # should add email service when implemented
      end
    end

    private

    def phone_number_formatted
      @rdv_solidarites_user.phone_number_formatted
    end

    def invitation_format
      @invitation.format
    end
  end
end
