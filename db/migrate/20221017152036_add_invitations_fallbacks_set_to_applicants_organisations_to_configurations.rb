class AddInvitationsFallbacksSetToApplicantsOrganisationsToConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :invitation_fallbacks_set_to_applicants_organisations, :boolean, default: false

    remove_column :configurations, :signature_lines, :string
  end
end
