describe Stat do
  include_context "with all existing categories"

  describe "department_number validation" do
    context "when the department_number is present" do
      let!(:stat) { build(:stat, department_number: "1") }

      it "is valid" do
        expect(stat).to be_valid
      end
    end

    context "when no department_number is given" do
      let!(:stat) { build(:stat, department_number: nil) }

      it "adds errors" do
        expect(stat).not_to be_valid
        expect(stat.errors.details).to eq({ department_number: [{ :error => :blank }] })
        expect(stat.errors.full_messages.to_sentence)
          .to include("Department number doit être rempli(e)")
      end
    end
  end

  describe "instance_methods" do
    let!(:department) { create(:department) }
    let!(:stat) { build(:stat, department_number: department.number) }
    let(:date) { Time.zone.parse("17/03/2022 12:00") }
    let!(:other_department) { create(:department) }
    let!(:applicant1) do
      create(:applicant, organisations: [organisation],
                         created_at: date)
    end
    let!(:applicant2) do
      create(:applicant, organisations: [other_organisation],
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
    let!(:invitation1) do
      create(:invitation, applicant: applicant1, department: department, sent_at: date)
    end
    let!(:invitation2) do
      create(:invitation, applicant: applicant2, department: other_department, sent_at: date)
    end
    let!(:agent1) { create(:agent, organisations: [organisation], has_logged_in: true) }
    let!(:agent2) { create(:agent, organisations: [other_organisation], has_logged_in: true) }
    let!(:participation1) { create(:participation, rdv: rdv1, applicant: applicant1) }
    let!(:participation2) { create(:participation, rdv: rdv2, applicant: applicant2) }
    let!(:rdv_context1) do
      create(:rdv_context, applicant: applicant1, invitations: [invitation1],
                           participations: [participation1], motif_category: category_rsa_orientation)
    end
    let!(:rdv_context2) do
      create(:rdv_context, applicant: applicant2, invitations: [invitation2],
                           participations: [participation2], motif_category: category_rsa_orientation)
    end

    context "when department_number is not 'all'" do
      describe "#all_applicants" do
        it "scopes the collection to the department" do
          expect(stat.all_applicants).to include(applicant1)
          expect(stat.all_applicants).not_to include(applicant2)
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
          expect(stat.participations_sample).not_to include(participation2)
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

      describe "#applicants_sample" do
        let!(:applicant3) do
          create(:applicant, organisations: [organisation], deleted_at: date)
        end
        let!(:applicant4) do
          create(:applicant, organisations: [organisation])
        end
        let!(:archiving) { create(:archiving, applicant: applicant4, department: department) }
        let!(:applicant5) do
          create(:applicant, organisations: [organisation_with_no_configuration])
        end

        it "scopes the collection to the department" do
          expect(stat.applicants_sample).to include(applicant1)
          expect(stat.applicants_sample).not_to include(applicant2)
        end

        it "does not include the deleted applicants" do
          expect(stat.applicants_sample).not_to include(applicant3)
        end

        it "does not include the archived applicants" do
          expect(stat.applicants_sample).not_to include(applicant4)
        end

        it "does not include the applicant from irrelevant organisations" do
          expect(stat.applicants_sample).not_to include(applicant5)
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
        let!(:applicant3) { create(:applicant, organisations: [organisation]) }
        let!(:rdv3) { create(:rdv, organisation: organisation) }
        let!(:participation3) { create(:participation, rdv: rdv3) }
        let!(:rdv_context3) { create(:rdv_context, applicant: applicant3, participations: [participation3]) }
        let!(:applicant4) { create(:applicant, organisations: [organisation]) }
        let!(:invitation4) { create(:invitation) }
        let!(:rdv4) { create(:rdv, organisation: organisation) }
        let!(:participation4) { create(:participation, rdv: rdv4) }
        let!(:rdv_context4) do
          create(:rdv_context, applicant: applicant4, invitations: [invitation4], participations: [participation4])
        end
        let!(:applicant5) { create(:applicant, organisations: [organisation]) }
        let!(:invitation5) { create(:invitation) }
        let!(:rdv_context5) do
          create(:rdv_context, applicant: applicant5, invitations: [invitation5])
        end
        let!(:applicant6) do
          create(:applicant, organisations: [organisation_with_no_configuration])
        end
        let!(:invitation6) { create(:invitation, sent_at: date) }
        let!(:rdv6) { create(:rdv, organisation: organisation) }
        let!(:participation6) { create(:participation, rdv: rdv6) }
        let!(:rdv_context6) do
          create(:rdv_context, applicant: applicant6, invitations: [invitation6], participations: [participation6])
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

        it "does not include the rdv_contexts of applicants from irrelevant organisations" do
          expect(stat.rdv_contexts_sample).not_to include(rdv_context6)
        end
      end

      describe "#rdvs_non_collectifs_sample" do
        let!(:applicant3) do
          create(:applicant, organisations: [organisation])
        end
        let!(:rdv3) { create(:rdv, organisation: organisation, motif: motif_collectif) }
        let!(:participation3) { create(:participation, rdv: rdv3, applicant: applicant3) }

        it "does not include collectifs rdvs" do
          expect(stat.rdvs_non_collectifs_sample).not_to include(rdv3)
        end
      end

      describe "#invited_applicants_with_rdvs_non_collectifs_sample" do
        let!(:applicant3) do
          create(:applicant, organisations: [organisation_with_no_configuration])
        end
        let!(:applicant4) { create(:applicant, organisations: [organisation]) }
        let!(:applicant5) { create(:applicant, organisations: [organisation]) }
        let!(:applicant6) { create(:applicant, organisations: [organisation]) }
        let!(:applicant7) { create(:applicant, organisations: [organisation]) }
        let!(:invitation3) { create(:invitation, applicant: applicant3, department: department, sent_at: date) }
        let!(:invitation5) { create(:invitation, applicant: applicant5, department: department) }
        let!(:invitation6) { create(:invitation, applicant: applicant6, department: department, sent_at: date) }
        let!(:invitation7) { create(:invitation, applicant: applicant7, department: department, sent_at: date) }
        let!(:rdv3) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv4) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv5) { create(:rdv, organisation: organisation, created_by: "user", motif: motif) }
        let!(:rdv7) { create(:rdv, organisation: organisation, created_by: "user", motif: motif_collectif) }
        let!(:participation3) { create(:participation, rdv: rdv3, applicant: applicant3) }
        let!(:participation4) { create(:participation, rdv: rdv4, applicant: applicant4) }
        let!(:participation5) { create(:participation, rdv: rdv5, applicant: applicant5) }
        let!(:participation7) { create(:participation, rdv: rdv7, applicant: applicant7) }

        it "scopes the collection to the department" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).to include(applicant1)
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).not_to include(applicant2)
        end

        it "does not include the applicant from irrelevant organisations" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).not_to include(applicant3)
        end

        it "does not include the applicants whith no invitations" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).not_to include(applicant4)
        end

        it "does not include the applicants whith no sent invitation" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).not_to include(applicant5)
        end

        it "does not include the applicants whith no rdvs" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).not_to include(applicant6)
        end

        it "does not include the applicants whith collectifs rdvs" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).not_to include(applicant7)
        end
      end

      describe "#applicants_for_30_days_rdvs_seen_sample" do
        let!(:applicant3) do
          create(:applicant, organisations: [organisation],
                             created_at: date)
        end
        let!(:rdv_context3) do
          create(:rdv_context, applicant: applicant3, motif_category: category_rsa_cer_signature)
        end

        it "scopes the collection to the department" do
          expect(stat.applicants_for_30_days_rdvs_seen_sample).to include(applicant1)
          expect(stat.applicants_for_30_days_rdvs_seen_sample).not_to include(applicant2)
        end

        it "does not include the applicants with no motif category for a first rdv RSA" do
          expect(stat.applicants_for_30_days_rdvs_seen_sample).not_to include(applicant3)
        end
      end
    end

    context "when department_number is 'all'" do
      let!(:department_number) { "all" }
      let!(:stat) { build(:stat, department_number: department_number) }

      describe "#all_applicants" do
        it "does not scope the collection to the department" do
          expect(stat.all_applicants).to include(applicant2)
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

      describe "#applicants_sample" do
        it "does not scope the collection to the department" do
          expect(stat.applicants_sample).to include(applicant2)
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

      describe "#invited_applicants_with_rdvs_non_collectifs_sample" do
        it "does not scope the collection to the department" do
          expect(stat.invited_applicants_with_rdvs_non_collectifs_sample).to include(applicant2)
        end
      end

      describe "#applicants_for_30_days_rdvs_seen_sample" do
        it "does not scope the collection to the department" do
          expect(stat.applicants_for_30_days_rdvs_seen_sample).to include(applicant2)
        end
      end
    end
  end
end
