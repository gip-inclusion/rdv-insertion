module Messengers
  class SendEmail < BaseService
    def initialize(sendable:, mailer_class:, mailer_method:, **email_args)
      @sendable = sendable
      @mailer_class = mailer_class
      @mailer_method = mailer_method
      @email_args = email_args
    end

    def call
      check_invitation_format!
      check_email!
      send_email
    end

    private

    def check_invitation_format!
      fail!("Envoi d'un email alors que le format est #{@sendable.format}") unless @sendable.format == "email"
    end

    def check_email!
      fail!("L'email doit être renseigné") if @sendable.email.blank?
      fail!("L'email renseigné ne semble pas être une adresse valable") if (@sendable.email =~ URI::MailTo::EMAIL_REGEXP).nil?
    end

    def send_email
      @mailer_class.with(@email_args).send(@mailer_method).deliver_now
    end
  end
end
