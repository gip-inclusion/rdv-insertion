module Templatable
  delegate :rdv_purpose, :rdv_title_by_phone, :rdv_title, :applicant_designation, :display_mandatory_warning,
           :display_punishable_warning, :rdv_subject,
           to: :motif_category_settings

  def motif_category_settings
    @motif_category_settings ||= Templating::MotifCategoriesSettings.send(:"#{motif_category}")
  end
end
