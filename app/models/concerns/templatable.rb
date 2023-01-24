module Templatable
  delegate :rdv_purpose, :rdv_title_by_phone, :rdv_title, :applicant_designation, :display_mandatory_warning,
           :display_punishable_warning, :rdv_subject,
           to: :motif_category_wordings

  def motif_category_wordings
    @motif_category_wordings ||= Templating::MotifCategoriesWordings.send(:"#{motif_category}")
  end
end
