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
      generate_letter_content
      generate_pdf
    end

    private

    def generate_letter_content
      @content = ApplicationController.render(
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
      pdf_result = PdfGeneration::Generate.call(
        content: @content,
        context: { invitation_id: @invitation.id }
      )

      if pdf_result.success?
        @invitation.pdf_data = pdf_result.pdf_data
      else
        result.error_type = pdf_result.error_type
        fail!(pdf_result.errors.first)
      end
    end
  end
end
