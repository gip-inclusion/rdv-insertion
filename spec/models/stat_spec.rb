describe Stat do
  include_context "with all existing categories"

  describe "instance_methods" do
    let!(:department) { create(:department) }
    let!(:stat) { build(:stat, statable_type: structure_type, statable_id: structure_id) }
    let(:date) { Time.zone.parse("17/07/2023 12:00") }
    let!(:other_department) { create(:department) }
    let!(:user1) do
      create(:user, organisations: [organisation],
                    created_at: date)
    end
    let!(:user2) do
      create(:user, organisations: [other_organisation],
                    created_at: date)
    end
    let!(:organisation) { create(:organisation, department: department) }
    let!(:configuration) { create(:configuration, organisation: organisation) }
    let!(:organisation_with_no_configuration) { create(:organisation, department: department) }
    let!(:other_organisation) { create(:organisation, department: other_department) }
    let!(:other_configuration) { create(:configuration, organisation: other_organisation) }
    let!(:motif) { create(:motif, collectif: false) }
    let!(:motif_collectif) { create(:motif, collectif: true) }
    let!(:rdv1) { create(:rdv, organisation: organisation, created_by: "user", motif: motif, starts_at: date) }
    let!(:rdv2) { create(:rdv, organisation: other_organisation, created_by: "user", motif: motif) }
    let!(:rdv3) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
    let!(:invitation1) do
      create(:invitation, user: user1, department: department, sent_at: date)
    end
    let!(:invitation2) do
      create(:invitation, user: user2, department: other_department, sent_at: date)
    end
    let!(:agent1) { create(:agent, organisations: [organisation], has_logged_in: true) }
    let!(:agent2) { create(:agent, organisations: [other_organisation], has_logged_in: true) }
    let!(:participation1) { create(:participation, rdv: rdv1, user: user1) }
    let!(:participation2) { create(:participation, rdv: rdv2, user: user2) }
    let!(:participation3) { create(:participation, rdv: rdv3, user: user1) }
    let!(:notification) { create(:notification, participation: participation3) }
    let!(:rdv_context1) do
      create(:rdv_context, user: user1, invitations: [invitation1],
                           participations: [participation1], motif_category: category_rsa_orientation)
    end
    let!(:rdv_context2) do
      create(:rdv_context, user: user2, invitations: [invitation2],
                           participations: [participation2], motif_category: category_rsa_orientation)
    end
    let!(:structure_type) { "Department" }
    let!(:structure_id) { department.id }

    context "when statable type is Department and statable_id is present" do
      describe "#all_users" do
        it "scopes the collection to the department" do
          expect(stat.all_users).to include(user1)
          expect(stat.all_users).not_to include(user2)
        end
      end

      describe "#all_organisations" do
        it "scopes the collection to the department" do
          expect(stat.all_organisations).to include(organisation)
          expect(stat.all_organisations).not_to include(other_organisation)
        end
      end

      describe "#all_participations" do
        it "scopes the collection to the department" do
          expect(stat.all_participations).to include(participation1)
          expect(stat.all_participations).not_to include(participation2)
          expect(stat.all_participations).to include(participation3)
        end
      end

      describe "#invitations_sample" do
        let!(:invitation3) { create(:invitation, department: department, sent_at: nil) }

        it "scopes the collection to the department" do
          expect(stat.invitations_sample).to include(invitation1)
          expect(stat.invitations_sample).not_to include(invitation2)
        end

        it "scopes the collection to sent invitations" do
          expect(stat.invitations_sample).not_to include(invitation3)
        end
      end

      describe "#participations_sample" do
        it "scopes the collection to the department" do
          expect(stat.participations_sample).to include(participation1)
          expect(stat.participations_sample).to include(participation3)
          expect(stat.participations_sample).not_to include(participation2)
        end
      end

      describe "#participations_without_notifications_sample" do
        it "scopes the collection to the department" do
          expect(stat.participations_without_notifications_sample).to include(participation1)
          expect(stat.participations_without_notifications_sample).not_to include(participation2)
          expect(stat.participations_without_notifications_sample).not_to include(participation3)
        end
      end

      describe "#participations_with_notifications_sample" do
        it "scopes the collection to the department" do
          expect(stat.participations_with_notifications_sample).not_to include(participation1)
          expect(stat.participations_with_notifications_sample).not_to include(participation2)
          expect(stat.participations_with_notifications_sample).to include(participation3)
        end
      end

      describe "#organisations_sample" do
        let!(:organisation_with_no_invitations_formats) { create(:organisation, department: department) }
        let!(:configuration_with_no_invitations_formats) do
          create(:configuration, organisation: organisation_with_no_invitations_formats, invitation_formats: [])
        end

        it "scopes the collection to the department" do
          expect(stat.organisations_sample).to include(organisation)
          expect(stat.organisations_sample).not_to include(other_organisation)
        end

        it "scopes the collection to the ones with an active configuration" do
          expect(stat.organisations_sample).not_to include(organisation_with_no_invitations_formats)
          expect(stat.organisations_sample).not_to include(organisation_with_no_configuration)
        end
      end

      describe "#users_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation], deleted_at: date)
        end
        let!(:user4) do
          create(:user, organisations: [organisation])
        end
        let!(:archive) { create(:archive, user: user4, department: department) }
        let!(:user5) do
          create(:user, organisations: [organisation_with_no_configuration])
        end

        it "scopes the collection to the department" do
          expect(stat.users_sample).to include(user1)
          expect(stat.users_sample).not_to include(user2)
        end

        it "does not include the deleted users" do
          expect(stat.users_sample).not_to include(user3)
        end

        it "does not include the archived users" do
          expect(stat.users_sample).not_to include(user4)
        end

        it "does not include the user from irrelevant organisations" do
          expect(stat.users_sample).not_to include(user5)
        end
      end

      describe "#agents_sample" do
        let!(:agent3) { create(:agent, organisations: [organisation], has_logged_in: true, email: "a@beta.gouv.fr") }
        let!(:agent4) { create(:agent, organisations: [organisation], has_logged_in: false) }

        it "scopes the collection to the department" do
          expect(stat.agents_sample).to include(agent1)
          expect(stat.agents_sample).not_to include(agent2)
        end

        it "does not include the betagouv agents" do
          expect(stat.agents_sample).not_to include(agent3)
        end

        it "does not include the agents who never logged in" do
          expect(stat.agents_sample).not_to include(agent4)
        end
      end

      describe "#rdv_contexts_sample" do
        let!(:user3) { create(:user, organisations: [organisation]) }
        let!(:rdv3) { create(:rdv, organisation: organisation) }
        let!(:participation3) { create(:participation, rdv: rdv3) }
        let!(:rdv_context3) { create(:rdv_context, user: user3, participations: [participation3]) }
        let!(:user4) { create(:user, organisations: [organisation]) }
        let!(:invitation4) { create(:invitation) }
        let!(:rdv4) { create(:rdv, organisation: organisation) }
        let!(:participation4) { create(:participation, rdv: rdv4) }
        let!(:rdv_context4) do
          create(:rdv_context, user: user4, invitations: [invitation4], participations: [participation4])
        end
        let!(:user5) { create(:user, organisations: [organisation]) }
        let!(:invitation5) { create(:invitation) }
        let!(:rdv_context5) do
          create(:rdv_context, user: user5, invitations: [invitation5])
        end
        let!(:user6) do
          create(:user, organisations: [organisation_with_no_configuration])
        end
        let!(:invitation6) { create(:invitation, sent_at: date) }
        let!(:rdv6) { create(:rdv, organisation: organisation) }
        let!(:participation6) { create(:participation, rdv: rdv6) }
        let!(:rdv_context6) do
          create(:rdv_context, user: user6, invitations: [invitation6], participations: [participation6])
        end

        it "scopes the collection to the department" do
          expect(stat.rdv_contexts_sample).to include(rdv_context1)
          expect(stat.rdv_contexts_sample).not_to include(rdv_context2)
        end

        it "does not include rdv_contexts with no invitations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context3)
        end

        it "does not include rdv_contexts with unsent invitations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context4)
        end

        it "does not include rdv_contexts with no rdvs" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context5)
        end

        it "does not include the rdv_contexts of users from irrelevant organisations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context6)
        end
      end

      describe "#rdvs_non_collectifs_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation])
        end
        let!(:rdv3) { create(:rdv, organisation: organisation, motif: motif_collectif) }
        let!(:participation3) { create(:participation, rdv: rdv3, user: user3) }

        it "does not include collectifs rdvs" do
          expect(stat.rdvs_non_collectifs_sample).not_to include(rdv3)
        end
      end

      describe "#invited_users_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation_with_no_configuration])
        end
        let!(:user4) { create(:user, organisations: [organisation]) }
        let!(:user5) { create(:user, organisations: [organisation]) }
        let!(:user6) { create(:user, organisations: [organisation]) }
        let!(:invitation3) { create(:invitation, user: user3, department: department, sent_at: date) }
        let!(:invitation5) { create(:invitation, user: user5, department: department) }
        let!(:invitation6) { create(:invitation, user: user6, department: department, sent_at: date) }
        let!(:rdv3) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv4) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv5) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:participation3) { create(:participation, rdv: rdv3, user: user3) }
        let!(:participation4) { create(:participation, rdv: rdv4, user: user4) }
        let!(:participation5) { create(:participation, rdv: rdv5, user: user5) }

        it "scopes the collection to the department" do
          expect(stat.invited_users_sample).to include(user1)
          expect(stat.invited_users_sample).not_to include(user2)
        end

        it "does not include the user from irrelevant organisations" do
          expect(stat.invited_users_sample).not_to include(user3)
        end

        it "does not include the users whith no invitations" do
          expect(stat.invited_users_sample).not_to include(user4)
        end

        it "does not include the users whith no sent invitation" do
          expect(stat.invited_users_sample).not_to include(user5)
        end

        it "includes the invited users whith no rdvs" do
          expect(stat.invited_users_sample).to include(user6)
        end
      end

      describe "#users_for_30_days_rdvs_seen_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation],
                        created_at: date)
        end
        let!(:rdv_context3) do
          create(:rdv_context, user: user3, motif_category: category_rsa_cer_signature)
        end

        it "scopes the collection to the department" do
          expect(stat.users_for_30_days_rdvs_seen_sample).to include(user1)
          expect(stat.users_for_30_days_rdvs_seen_sample).not_to include(user2)
        end

        it "does not include the users with no motif category for a first rdv RSA" do
          expect(stat.users_for_30_days_rdvs_seen_sample).not_to include(user3)
        end
      end
    end

    context "when statable type is Organisation and statable_id is present" do
      let!(:structure_type) { "Organisation" }
      let!(:structure_id) { organisation.id }

      describe "#all_users" do
        it "scopes the collection to the organisation" do
          expect(stat.all_users).to include(user1)
          expect(stat.all_users).not_to include(user2)
        end
      end

      describe "#all_organisations" do
        it "scopes the collection to the organisation" do
          expect(stat.all_organisations).to include(organisation)
          expect(stat.all_organisations).not_to include(other_organisation)
        end
      end

      describe "#all_participations" do
        it "scopes the collection to the organisation" do
          expect(stat.all_participations).to include(participation1)
          expect(stat.all_participations).not_to include(participation2)
        end
      end

      describe "#invitations_sample" do
        let!(:invitation1) do
          create(:invitation, user: user1, organisations: [organisation], sent_at: date)
        end
        let!(:invitation2) do
          create(:invitation, user: user2, organisations: [other_organisation], sent_at: date)
        end
        let!(:invitation3) { create(:invitation, organisations: [organisation], sent_at: nil) }

        it "scopes the collection to the organisation" do
          expect(stat.invitations_sample).to include(invitation1)
          expect(stat.invitations_sample).not_to include(invitation2)
        end

        it "scopes the collection to sent invitations" do
          expect(stat.invitations_sample).not_to include(invitation3)
        end
      end

      describe "#participations_sample" do
        it "scopes the collection to the organisation" do
          expect(stat.participations_sample).to include(participation1)
          expect(stat.participations_sample).not_to include(participation2)
        end
      end

      describe "#organisations_sample" do
        let!(:organisation_with_no_invitations_formats) { create(:organisation, department: department) }
        let!(:configuration_with_no_invitations_formats) do
          create(:configuration, organisation: organisation_with_no_invitations_formats, invitation_formats: [])
        end

        it "scopes the collection to the organisation" do
          expect(stat.organisations_sample).to include(organisation)
          expect(stat.organisations_sample).not_to include(other_organisation)
        end

        it "scopes the collection to the ones with an active configuration" do
          expect(stat.organisations_sample).not_to include(organisation_with_no_invitations_formats)
          expect(stat.organisations_sample).not_to include(organisation_with_no_configuration)
        end
      end

      describe "#users_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation], deleted_at: date)
        end
        let!(:user4) do
          create(:user, organisations: [organisation])
        end
        let!(:archive) { create(:archive, user: user4, department: department) }
        let!(:user5) do
          create(:user, organisations: [organisation_with_no_configuration])
        end

        it "scopes the collection to the organisation" do
          expect(stat.users_sample).to include(user1)
          expect(stat.users_sample).not_to include(user2)
        end

        it "does not include the deleted users" do
          expect(stat.users_sample).not_to include(user3)
        end

        it "does not include the archived users" do
          expect(stat.users_sample).not_to include(user4)
        end

        it "does not include the user from irrelevant organisations" do
          expect(stat.users_sample).not_to include(user5)
        end
      end

      describe "#agents_sample" do
        let!(:agent3) { create(:agent, organisations: [organisation], has_logged_in: true, email: "a@beta.gouv.fr") }
        let!(:agent4) { create(:agent, organisations: [organisation], has_logged_in: false) }

        it "scopes the collection to the organisation" do
          expect(stat.agents_sample).to include(agent1)
          expect(stat.agents_sample).not_to include(agent2)
        end

        it "does not include the betagouv agents" do
          expect(stat.agents_sample).not_to include(agent3)
        end

        it "does not include the agents who never logged in" do
          expect(stat.agents_sample).not_to include(agent4)
        end
      end

      describe "#rdv_contexts_sample" do
        let!(:user3) { create(:user, organisations: [organisation]) }
        let!(:rdv3) { create(:rdv, organisation: organisation) }
        let!(:participation3) { create(:participation, rdv: rdv3) }
        let!(:rdv_context3) { create(:rdv_context, user: user3, participations: [participation3]) }
        let!(:user4) { create(:user, organisations: [organisation]) }
        let!(:invitation4) { create(:invitation) }
        let!(:rdv4) { create(:rdv, organisation: organisation) }
        let!(:participation4) { create(:participation, rdv: rdv4) }
        let!(:rdv_context4) do
          create(:rdv_context, user: user4, invitations: [invitation4], participations: [participation4])
        end
        let!(:user5) { create(:user, organisations: [organisation]) }
        let!(:invitation5) { create(:invitation) }
        let!(:rdv_context5) do
          create(:rdv_context, user: user5, invitations: [invitation5])
        end
        let!(:user6) do
          create(:user, organisations: [organisation_with_no_configuration])
        end
        let!(:invitation6) { create(:invitation, sent_at: date) }
        let!(:rdv6) { create(:rdv, organisation: organisation) }
        let!(:participation6) { create(:participation, rdv: rdv6) }
        let!(:rdv_context6) do
          create(:rdv_context, user: user6, invitations: [invitation6], participations: [participation6])
        end

        it "scopes the collection to the organisation" do
          expect(stat.rdv_contexts_sample).to include(rdv_context1)
          expect(stat.rdv_contexts_sample).not_to include(rdv_context2)
        end

        it "does not include rdv_contexts with no invitations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context3)
        end

        it "does not include rdv_contexts with unsent invitations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context4)
        end

        it "does not include rdv_contexts with no rdvs" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context5)
        end

        it "does not include the rdv_contexts of users from irrelevant organisations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context6)
        end
      end

      describe "#rdvs_non_collectifs_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation])
        end
        let!(:rdv3) { create(:rdv, organisation: organisation, motif: motif_collectif) }
        let!(:participation3) { create(:participation, rdv: rdv3, user: user3) }

        it "does not include collectifs rdvs" do
          expect(stat.rdvs_non_collectifs_sample).not_to include(rdv3)
        end
      end

      describe "#invited_users_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation_with_no_configuration])
        end
        let!(:user4) { create(:user, organisations: [organisation]) }
        let!(:user5) { create(:user, organisations: [organisation]) }
        let!(:user6) { create(:user, organisations: [organisation]) }
        let!(:invitation3) { create(:invitation, user: user3, department: department, sent_at: date) }
        let!(:invitation5) { create(:invitation, user: user5, department: department) }
        let!(:invitation6) { create(:invitation, user: user6, department: department, sent_at: date) }
        let!(:rdv3) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv4) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv5) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:participation3) { create(:participation, rdv: rdv3, user: user3) }
        let!(:participation4) { create(:participation, rdv: rdv4, user: user4) }
        let!(:participation5) { create(:participation, rdv: rdv5, user: user5) }

        it "scopes the collection to the organisation" do
          expect(stat.invited_users_sample).to include(user1)
          expect(stat.invited_users_sample).not_to include(user2)
        end

        it "does not include the user from irrelevant organisations" do
          expect(stat.invited_users_sample).not_to include(user3)
        end

        it "does not include the users whith no invitations" do
          expect(stat.invited_users_sample).not_to include(user4)
        end

        it "does not include the users whith no sent invitation" do
          expect(stat.invited_users_sample).not_to include(user5)
        end

        it "includes the users whith no rdvs" do
          expect(stat.invited_users_sample).to include(user6)
        end
      end

      describe "#users_for_30_days_rdvs_seen_sample" do
        let!(:user3) do
          create(:user, organisations: [organisation],
                        created_at: date)
        end
        let!(:rdv_context3) do
          create(:rdv_context, user: user3, motif_category: category_rsa_cer_signature)
        end

        it "scopes the collection to the organisation" do
          expect(stat.users_for_30_days_rdvs_seen_sample).to include(user1)
          expect(stat.users_for_30_days_rdvs_seen_sample).not_to include(user2)
        end

        it "does not include the users with no motif category for a first rdv RSA" do
          expect(stat.users_for_30_days_rdvs_seen_sample).not_to include(user3)
        end
      end
    end

    context "when it is the stat record for all departments" do
      let!(:stat) { build(:stat, statable_type: "Department", statable_id: nil) }

      describe "#all_users" do
        it "does not scope the collection to the department" do
          expect(stat.all_users).to include(user2)
        end
      end

      describe "#all_organisations" do
        it "does not scope the collection to the department" do
          expect(stat.all_organisations).to include(other_organisation)
        end
      end

      describe "#all_participations" do
        it "does not scope the collection to the department" do
          expect(stat.all_participations).to include(participation2)
        end
      end

      describe "#invitations_sample" do
        it "does not scope the collection to the department" do
          expect(stat.invitations_sample).to include(invitation2)
        end
      end

      describe "#participations_sample" do
        it "does not scope the collection to the department" do
          expect(stat.participations_sample).to include(participation2)
        end
      end

      describe "#organisations_sample" do
        it "does not scope the collection to the department" do
          expect(stat.organisations_sample).to include(other_organisation)
        end
      end

      describe "#users_sample" do
        it "does not scope the collection to the department" do
          expect(stat.users_sample).to include(user2)
        end
      end

      describe "#agents_sample" do
        it "does not scope the collection to the department" do
          expect(stat.agents_sample).to include(agent1)
          expect(stat.agents_sample).to include(agent2)
        end
      end

      describe "#rdv_contexts_sample" do
        it "does not scope the collection to the department" do
          expect(stat.rdv_contexts_sample).to include(rdv_context2)
        end
      end

      describe "#invited_users_sample" do
        it "does not scope the collection to the department" do
          expect(stat.invited_users_sample).to include(user2)
        end
      end

      describe "#users_for_30_days_rdvs_seen_sample" do
        it "does not scope the collection to the department" do
          expect(stat.users_for_30_days_rdvs_seen_sample).to include(user2)
        end
      end
    end
  end
end
