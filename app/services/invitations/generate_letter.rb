module Invitations
  class GenerateLetter < BaseService
    include Templatable

    attr_reader :invitation

    delegate :applicant, :department, :motif_category, :messages_configuration,
             :letter_sender_name, :address, :street_address, :zipcode_and_city,
             :signature_lines, :display_europe_logos, :direction_names, :help_address,
             :sender_city, :display_department_logo, :atelier?, :phone_platform?,
             to: :invitation

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_address!
      check_messages_configuration!
      generate_letter
    end

    private

    def generate_letter
      @invitation.content = ApplicationController.render(
        template: "letters/#{template}",
        layout: "pdf",
        locals: locals
      )
    end

    def check_invitation_format!
      fail!("Génération d'une lettre alors que le format est #{@invitation.format}") unless @invitation.format_postal?
    end

    def check_address!
      fail!("L'adresse doit être renseignée") if address.blank?
      fail!("Le format de l'adresse est invalide") if street_address.blank? || zipcode_and_city.blank?
    end

    def template
      @template ||= \
        if atelier?
          "invitation_for_atelier"
        elsif phone_platform?
          "invitation_for_phone_platform"
        else
          "regular_invitation"
        end
    end

    def locals
      {
        invitation: @invitation,
        department: department,
        applicant: applicant,
        organisation: organisation,
        sender_name: letter_sender_name,
        direction_names: direction_names,
        signature_lines: signature_lines,
        help_address: help_address,
        display_europe_logos: display_europe_logos,
        display_independent_from_cd_message: display_independent_from_cd_message,
        display_department_logo: display_department_logo,
        sender_city: sender_city,
        rdv_title: rdv_title,
        rdv_subject: rdv_subject,
        applicant_designation: applicant_designation,
        display_mandatory_warning: display_mandatory_warning,
        display_punishable_warning: display_punishable_warning,
        rdv_purpose: rdv_purpose,
        rdv_subject: rdv_subject
      }
    end

    def check_messages_configuration!
      return if messages_configuration.present? && messages_configuration.direction_names.present?

      fail!("La configuration des courriers pour votre organisation est incomplète")
    end

    def organisation
      (applicant.organisations & @invitation.organisations).last
    end

    def display_independent_from_cd_message
      @invitation.organisations.all?(&:independent_from_cd)
    end
  end
end
