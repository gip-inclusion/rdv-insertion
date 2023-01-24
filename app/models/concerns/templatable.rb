module Templatable
  delegate :rdv_purpose, :rdv_title_by_phone, :rdv_title, :applicant_designation, :display_mandatory_warning,
           :display_punishable_warning, :rdv_subject,
           to: :message_template

  private

  def message_template
    @message_template ||= Templating::ApplicantMessages.send(:"#{motif_category}")
  end
end
