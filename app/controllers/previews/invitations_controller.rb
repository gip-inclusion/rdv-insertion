module Previews
  class InvitationsController < Previews::BaseController
    before_action :set_configuration, :set_template, :set_organisation, :set_motif_category, :set_department,
                  :set_applicant_example, :set_invitation_example, only: [:index]

    attr_reader :applicant, :invitation

    include Invitations::SmsContent

    def index
      set_and_format_contents
    end

    private

    def set_template
      @template = @configuration.template
    end

    def set_configuration
      @configuration = ::Configuration.find(params[:configuration_id])
    end

    def set_organisation
      @organisation = @configuration.organisation
    end

    def set_department
      @department = @organisation.department
    end

    def set_motif_category
      @motif_category = @configuration.motif_category
    end

    def set_invitation_example
      @invitation = Invitation.new(
        applicant: @applicant, organisations: [@organisation],
        rdv_context: RdvContext.new(motif_category: @motif_category),
        valid_until: @configuration.number_of_days_before_action_required.days.from_now,
        help_phone_number: @organisation.phone_number,
        department: @department,
        uuid: SecureRandom.send(:choose, [*"A".."Z", *"0".."9"], 8)
      )
      # needed to access @invitation.configurations when the record linking @invitation and @organisation is not persisted
      @invitation.association(:configurations).instance_variable_set("@target", [@configuration])
    end

    def set_applicant_example
      @applicant = Applicant.new(
        first_name: "Lara", last_name: "Croft", title: "madame",
        address: "160 rue saint Maur, 75011 Paris"
      )
    end

    def set_sms_contents
      @sms_contents = {
        first_invitation: send("#{@template.model}_content"),
        invitation_reminder: send("#{@template.model}_reminder_content")
      }
    end

    def set_mail_contents
      @mail_contents = {
        first_invitation: ApplicationController.render(
          template: "mailers/invitation_mailer/#{@template.model}_invitation",
          assigns: mailer_instance_variables,
          layout: nil
        ),
        invitation_reminder: ApplicationController.render(
          template: "mailers/invitation_mailer/#{@template.model}_invitation_reminder",
          assigns: mailer_instance_variables,
          layout: nil
        )
      }
    end

    def set_letter_contents
      @letter_contents = {
        first_invitation: ApplicationController.render(
          template: "letters/invitations/#{@template.model}",
          layout: nil,
          locals: letter_locals
        )
      }
    end

    def mailer_instance_variables
      {
        applicant: @applicant,
        invitation: @invitation,
        department: @invitation.department,
        applicant_designation: @invitation.applicant_designation,
        rdv_title: @invitation.rdv_title,
        rdv_purpose: @invitation.rdv_purpose,
        rdv_subject: @invitation.rdv_subject,
        mandatory_warning: @invitation.mandatory_warning,
        punishable_warning: @invitation.punishable_warning,
        custom_sentence: @invitation.custom_sentence,
        signature_lines: @organisation.messages_configuration&.signature_lines,
        organisation_logo_path: @organisation.logo_path(%w[png jpg]),
        department_logo_path: @department.logo_path(%w[png jpg])
      }
    end

    def letter_locals
      {
        invitation: @invitation,
        department: @department,
        applicant: @applicant,
        organisation: @organisation,
        sender_name: @invitation.letter_sender_name,
        direction_names: @invitation.direction_names,
        signature_lines: @invitation.signature_lines,
        help_address: @invitation.help_address,
        display_europe_logos: @invitation.display_europe_logos,
        display_department_logo: @invitation.display_department_logo,
        display_pole_emploi_logo: @invitation.display_pole_emploi_logo,
        sender_city: @invitation.sender_city,
        rdv_title: @invitation.rdv_title,
        applicant_designation: @invitation.applicant_designation,
        mandatory_warning: @invitation.mandatory_warning,
        punishable_warning: @invitation.punishable_warning,
        rdv_purpose: @invitation.rdv_purpose,
        rdv_subject: @invitation.rdv_subject,
        custom_sentence: @invitation.custom_sentence
      }
    end

    def overridable_texts
      Template::OVERRIDABLE_ATTRIBUTES.map do |attribute|
        @invitation.send(attribute)
      end
    end
  end
end
