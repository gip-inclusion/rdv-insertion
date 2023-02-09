module Invitations
  class GenerateLetter < BaseService
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
        template: "letters/#{@invitation.template_model}_invitation",
        layout: "pdf",
        locals: locals
      )
    end

    def check_invitation_format!
      fail!("Génération d'une lettre alors que le format est #{@invitation.format}") unless @invitation.format_postal?
    end

    def check_address!
      fail!("L'adresse doit être renseignée") if @invitation.address.blank?
      fail!("Le format de l'adresse est invalide") \
        if @invitation.street_address.blank? || @invitation.zipcode_and_city.blank?
    end

    def locals
      {
        invitation: @invitation,
        department: @invitation.department,
        applicant: @invitation.applicant,
        organisation: organisation,
        sender_name: @invitation.letter_sender_name,
        direction_names: @invitation.direction_names,
        signature_lines: @invitation.signature_lines,
        help_address: @invitation.help_address,
        display_europe_logos: @invitation.display_europe_logos,
        display_independent_from_cd_message: display_independent_from_cd_message,
        display_department_logo: @invitation.display_department_logo,
        sender_city: @invitation.sender_city,
        rdv_title: @invitation.rdv_title,
        applicant_designation: @invitation.applicant_designation,
        display_mandatory_warning: @invitation.display_mandatory_warning,
        display_punishable_warning: @invitation.display_punishable_warning,
        rdv_purpose: @invitation.rdv_purpose,
        rdv_subject: @invitation.rdv_subject
      }
    end

    def check_messages_configuration!
      return if @invitation.direction_names.present?

      fail!("La configuration des courriers pour votre organisation est incomplète")
    end

    def organisation
      (@invitation.applicant.organisations & @invitation.organisations).last
    end

    def display_independent_from_cd_message
      @invitation.organisations.all?(&:independent_from_cd)
    end
  end
end
