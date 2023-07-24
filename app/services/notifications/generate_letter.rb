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
      verify_applicant_phone_number! if @notification.rdv.by_phone?
      generate_letter
    end

    private

    def generate_letter
      @notification.content = ApplicationController.render(
        template: "letters/notifications/#{template}",
        layout: "pdf",
        locals: locals
      )
    end

    def locals
      {
        department: @notification.department,
        applicant: @notification.applicant,
        rdv: @notification.rdv,
        sender_name: @notification.letter_sender_name,
        direction_names: @notification.direction_names,
        signature_lines: @notification.signature_lines,
        organisation: @notification.organisation,
        display_europe_logos: @notification.display_europe_logos,
        display_department_logo: @notification.display_department_logo,
        display_pole_emploi_logo: @notification.display_pole_emploi_logo,
        sender_city: @notification.sender_city,
        rdv_title: @notification.rdv_title,
        rdv_title_by_phone: @notification.rdv_title_by_phone,
        applicant_designation: @notification.applicant_designation,
        mandatory_warning: @notification.mandatory_warning,
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
      end
    end

    def verify_notification_event!
      return if @notification.event.in?(%w[participation_created participation_cancelled])

      fail!("L'évènement #{@notification.event} n'est pas pris en charge pour le courrier")
    end

    def verify_applicant_phone_number!
      fail!("Le numéro de téléphone de l'allocataire n'est pas renseigné") \
        if @notification.applicant.phone_number.blank?
      fail!("Le numéro de téléphone de l'allocataire n'est pas un mobile") \
        unless @notification.applicant.phone_number_is_mobile?
    end
  end
end
