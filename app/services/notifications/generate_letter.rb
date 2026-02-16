module Notifications
  class GenerateLetter < BaseService
    include Messengers::GenerateLetter

    def initialize(notification:)
      @notification = notification
    end

    def call
      verify_format!(@notification)
      verify_address!(@notification)
      verify_notification_event!
      verify_user_phone_number! if @notification.rdv.by_phone?
      generate_letter_content
      generate_pdf(sendable: @notification, content: @content)
    end

    private

    def generate_letter_content
      @content = ApplicationController.render(
        template: "letters/notifications/#{template}",
        layout: "pdf",
        locals: locals
      )
    end

    def locals
      {
        department: @notification.department,
        user: @notification.user,
        rdv: @notification.rdv,
        motif_category: @notification.motif_category,
        sender_name: @notification.letter_sender_name,
        direction_names: @notification.direction_names,
        signature_lines: @notification.signature_lines,
        signature_image: @notification.signature_image,
        organisation: @notification.organisation,
        logos_to_display: @notification.logos_to_display,
        sender_city: @notification.sender_city,
        rdv_title: @notification.rdv_title,
        rdv_title_by_phone: @notification.rdv_title_by_phone,
        user_designation: @notification.user_designation,
        mandatory_warning: @notification.mandatory_warning(format: "letter"),
        punishable_warning: @notification.punishable_warning,
        instruction_for_rdv: @notification.instruction_for_rdv,
        rdv_purpose: @notification.rdv_purpose,
        rdv_subject: @notification.rdv_subject
      }
    end

    def template
      return "participation_cancelled" if @notification.event == "participation_cancelled"

      if @notification.rdv.presential?
        "presential_#{@notification.event}"
      elsif @notification.rdv.by_phone?
        "by_phone_#{@notification.event}"
      elsif @notification.rdv.visio?
        "visio_#{@notification.event}"
      end
    end

    def verify_notification_event!
      return if @notification.event.in?(%w[participation_created participation_cancelled])

      fail!("L'évènement #{@notification.event} n'est pas pris en charge pour le courrier")
    end

    def verify_user_phone_number!
      fail!("Le numéro de téléphone de l'usager n'est pas renseigné") \
        if @notification.user.phone_number.blank?
      fail!("Le numéro de téléphone de l'usager n'est pas un mobile") \
        unless @notification.user.phone_number_is_mobile?
    end
  end
end
