class AddWithReferentsToConfigurationsAndInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :rdv_with_referents, :boolean, default: false
    add_column :invitations, :rdv_with_referents, :boolean, default: false
  end
end
