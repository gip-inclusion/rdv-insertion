module Templatable
  delegate :rdv_purpose, :rdv_title_by_phone, :rdv_title, :applicant_designation, :mandatory_warning,
           :punishable_warning, :rdv_subject, :custom_sentence,
           to: :template
end
