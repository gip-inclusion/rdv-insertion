class AddOverrideTemplateAttributesToConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :template_rdv_title_override, :string
    add_column :configurations, :template_rdv_title_by_phone_override, :string
    add_column :configurations, :template_applicant_designation_override, :string
    add_column :configurations, :template_rdv_purpose_override, :string
  end
end
