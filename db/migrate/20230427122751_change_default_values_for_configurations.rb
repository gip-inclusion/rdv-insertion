class ChangeDefaultValuesForConfigurations < ActiveRecord::Migration[7.0]
  def change
    change_column_default :configurations, :convene_applicant, from: false, to: true
    change_column_default :configurations, :invite_to_applicant_organisations_only, from: false, to: true
  end
end
