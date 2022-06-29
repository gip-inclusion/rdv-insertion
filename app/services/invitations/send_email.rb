module Invitations
  class SendEmail < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_email!
      send_email
    end

    private

    def check_invitation_format!
      fail!("Envoi d'un email alors que le format est #{@invitation.format}") unless @invitation.format_email?
    end

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
      if @invitation.reminder?
        InvitationMailer.with(invitation: @invitation, applicant: applicant).send(
          :"invitation_for_#{@invitation.motif_category}_reminder"
        ).deliver_now
      else
        InvitationMailer.with(invitation: @invitation, applicant: applicant).send(
          :"invitation_for_#{@invitation.motif_category}"
        ).deliver_now
      end
    end
  end
end
