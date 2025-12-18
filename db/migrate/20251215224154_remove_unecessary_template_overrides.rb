class RemoveUnecessaryTemplateOverrides < ActiveRecord::Migration[8.0]
  # rubocop:disable Metrics/AbcSize
  def change
    up_only do
      CategoryConfiguration.find_each do |category_configuration|
        if category_configuration.template_rdv_title_override == category_configuration.template.rdv_title
          category_configuration.template_rdv_title_override = nil
        end
        if category_configuration.template_rdv_title_by_phone_override ==
           category_configuration.template.rdv_title_by_phone

          category_configuration.template_rdv_title_by_phone_override = nil
        end
        if category_configuration.template_user_designation_override ==
           category_configuration.template.user_designation

          category_configuration.template_user_designation_override = nil
        end
        if category_configuration.template_rdv_purpose_override == category_configuration.template.rdv_purpose
          category_configuration.template_rdv_purpose_override = nil
        end

        category_configuration.save! if category_configuration.changed?
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
