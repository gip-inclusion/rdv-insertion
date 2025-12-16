module CategoryConfiguration::TemplateOverride
  extend ActiveSupport::Concern

  included do
    nullify_blank :template_rdv_title_override, :template_rdv_title_by_phone_override,
                  :template_user_designation_override, :template_rdv_purpose_override
  end

  def default_template_rdv_title = template.rdv_title
  def default_template_rdv_title_by_phone = template.rdv_title_by_phone
  def default_template_user_designation = template.user_designation
  def default_template_rdv_purpose = template.rdv_purpose

  def template_rdv_title = template_rdv_title_override.presence || default_template_rdv_title
  def template_rdv_title_by_phone = template_rdv_title_by_phone_override.presence || default_template_rdv_title_by_phone
  def template_user_designation = template_user_designation_override.presence || default_template_user_designation
  def template_rdv_purpose = template_rdv_purpose_override.presence || default_template_rdv_purpose
end
