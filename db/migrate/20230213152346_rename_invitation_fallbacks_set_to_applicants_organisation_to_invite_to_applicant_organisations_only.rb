class RenameInvitationFallbacksSetToApplicantsOrganisationToInviteToApplicantOrganisationsOnly <
    ActiveRecord::Migration[7.0]
  def change
    rename_column :configurations,
                  :invitation_fallbacks_set_to_applicants_organisations,
                  :invite_to_applicant_organisations_only
  end
end
