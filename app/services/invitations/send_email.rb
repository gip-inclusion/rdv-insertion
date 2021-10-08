module Invitations
  class SendEmail < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_email!
      send_email
    end

    private

    def check_email!
      fail!("L'email doit être renseigné") if email.blank?
      fail!("L'email renseigné ne semble pas être une adresse valable") if (email =~ URI::MailTo::EMAIL_REGEXP).nil?
    end

    def email
      applicant.email
    end

    def applicant
      @invitation.applicant
    end

    def send_email
      return if Rails.env.development?

      InvitationMailer.first_invitation(@invitation, applicant).deliver_now
    end
  end
end
