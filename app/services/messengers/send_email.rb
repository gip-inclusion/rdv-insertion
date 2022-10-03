module Messengers
  class SendEmail < BaseService
    def initialize(sendable:, mailer_class:, mailer_method:, **email_args)
      @sendable = sendable
      @mailer_class = mailer_class
      @mailer_method = mailer_method
      @email_args = email_args
    end

    def call
      verify_invitation_format!
      verify_email!
      send_email
    end

    private

    def verify_invitation_format!
      fail!("Envoi d'un email alors que le format est #{@sendable.format}") unless @sendable.format == "email"
    end

    def verify_email!
      fail!("L'email doit être renseigné") if @sendable.email.blank?
      return unless (@sendable.email =~ URI::MailTo::EMAIL_REGEXP).nil?

      fail!("L'email renseigné ne semble pas être une adresse valable")
    end

    def send_email
      @mailer_class.with(@email_args).send(@mailer_method).deliver_now
    end
  end
end
