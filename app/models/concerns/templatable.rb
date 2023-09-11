module Templatable
  delegate :template, to: :motif_category
  delegate :mandatory_warning, :punishable_warning, :rdv_subject, :custom_sentence,
           to: :template

  def current_configuration
    @current_configuration ||= configurations.find { |c| c.motif_category == motif_category }
  end

  def rdv_title
    current_configuration&.template_rdv_title_override || template.rdv_title
  end

  def rdv_title_by_phone
    current_configuration&.template_rdv_title_by_phone_override || template.rdv_title_by_phone
  end

  def applicant_designation
    current_configuration&.template_applicant_designation_override || template.applicant_designation
  end

  def rdv_purpose
    current_configuration&.template_rdv_purpose_override || template.rdv_purpose
  end
end
