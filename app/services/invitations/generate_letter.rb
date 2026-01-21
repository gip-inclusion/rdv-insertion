module Invitations
  class GenerateLetter < BaseService
    require "rqrcode"

    include Messengers::GenerateLetter

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      verify_format!(@invitation)
      verify_address!(@invitation)
      generate_letter
      generate_pdf
    end

    private

    def generate_letter
      @invitation.content = ApplicationController.render(
        template: "letters/invitations/#{@invitation.template_model}",
        layout: "pdf",
        locals: locals
      )
    end

    def locals
      {
        invitation: @invitation,
        department: @invitation.department,
        user: @invitation.user,
        organisation: organisation,
        sender_name: @invitation.letter_sender_name,
        direction_names: @invitation.direction_names,
        signature_lines: @invitation.signature_lines,
        signature_image: @invitation.signature_image,
        help_address: @invitation.help_address,
        logos_to_display: @invitation.logos_to_display,
        sender_city: @invitation.sender_city,
        rdv_title: @invitation.rdv_title,
        user_designation: @invitation.user_designation,
        mandatory_warning: @invitation.mandatory_warning(format: "letter"),
        punishable_warning: @invitation.punishable_warning,
        rdv_purpose: @invitation.rdv_purpose,
        rdv_subject: @invitation.rdv_subject,
        custom_sentence: @invitation.custom_sentence,
        invitation_url: @invitation.rdv_solidarites_public_url(with_protocol: false),
        qr_code: @invitation.qr_code
      }
    end

    def organisation
      (@invitation.user.organisations & @invitation.organisations).last
    end

    def generate_pdf
      response = PdfGeneratorClient.generate_pdf(content: @invitation.content)
      handle_pdf_response(response)
    rescue Faraday::TimeoutError => e
      handle_pdf_error(:timeout, exception: e.class.name, message: e.message)
    rescue Faraday::ConnectionFailed => e
      handle_pdf_error(:connection_failed, exception: e.class.name, message: e.message)
    end

    def handle_pdf_response(response)
      if response.success?
        result.pdf_data = Base64.decode64(response.body)
      else
        handle_pdf_error(:server_error, status: response.status, body: response.body)
      end
    end

    def handle_pdf_error(error_type, extra_info = {})
      Sentry.capture_message("PDF generation failed", extra: { invitation_id: @invitation.id, **extra_info })
      result.error_type = error_type
      fail!(pdf_error_message(error_type))
    end

    def pdf_error_message(error_type)
      case error_type
      when :timeout
        "La génération du PDF a pris trop de temps. Veuillez réessayer dans quelques instants."
      when :connection_failed
        "Le service de génération de PDF est temporairement indisponible. Veuillez réessayer plus tard."
      when :server_error
        "Une erreur est survenue lors de la génération du PDF. " \
        "L'équipe a été notifiée de l'erreur et tente de la résoudre."
      end
    end
  end
end
