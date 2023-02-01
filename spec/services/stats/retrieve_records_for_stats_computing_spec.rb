describe Stats::RetrieveRecordsForStatsComputing, type: :service do
  subject do
    described_class.call(department_number: department_number)
  end

  let!(:department) { create(:department) }
  let!(:department_number) { department.number }
  let!(:other_department) { create(:department) }

  let!(:applicant1) { create(:applicant, department: department, organisations: [organisation]) }
  let!(:applicant2) { create(:applicant, department: other_department, organisations: [other_organisation]) }
  let!(:configuration) { create(:configuration) }
  let!(:organisation) { create(:organisation, department: department, configurations: [configuration]) }
  let!(:organisation_with_no_configuration) { create(:organisation, department: department) }
  let!(:other_organisation) { create(:organisation, department: other_department, configurations: [configuration]) }
  let!(:rdv1) { create(:rdv, organisation: organisation) }
  let!(:rdv2) { create(:rdv, organisation: other_organisation) }
  let!(:invitation1) { create(:invitation, department: department, sent_at: Time.zone.today) }
  let!(:invitation2) { create(:invitation, department: other_department, sent_at: Time.zone.today) }
  let!(:invitation3) { create(:invitation, department: department, sent_at: nil) }
  let!(:agent1) { create(:agent, organisations: [organisation], has_logged_in: true) }
  let!(:agent2) { create(:agent, organisations: [other_organisation], has_logged_in: true) }
  let!(:participation1) { create(:participation, rdv: rdv1, applicant: applicant1) }
  let!(:participation2) { create(:participation, rdv: rdv2, applicant: applicant2) }
  let!(:rdv_context1) do
    create(:rdv_context, applicant: applicant1, invitations: [invitation1], participations: [participation1])
  end
  let!(:rdv_context2) do
    create(:rdv_context, applicant: applicant2, invitations: [invitation2], participations: [participation2])
  end

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a hash of records" do
      expect(subject.data).to be_a(Hash)
    end

    it "renders all the records" do
      expect(subject.data).to include(:all_applicants)
      expect(subject.data).to include(:all_rdvs)
      expect(subject.data).to include(:sent_invitations)
      expect(subject.data).to include(:relevant_rdvs)
      expect(subject.data).to include(:relevant_rdv_contexts)
      expect(subject.data).to include(:relevant_applicants)
      expect(subject.data).to include(:relevant_agents)
      expect(subject.data).to include(:relevant_organisations)
    end

    context "all_applicants" do
      it "scopes the collection to the department" do
        expect(subject.data[:all_applicants]).to include(applicant1)
        expect(subject.data[:all_applicants]).not_to include(applicant2)
      end
    end

    context "all_rdvs" do
      it "scopes the collection to the department" do
        expect(subject.data[:all_rdvs]).to include(rdv1)
        expect(subject.data[:all_rdvs]).not_to include(rdv2)
      end
    end

    context "sent_invitations" do
      it "scopes the collection to the department" do
        expect(subject.data[:sent_invitations]).to include(invitation1)
        expect(subject.data[:sent_invitations]).not_to include(invitation2)
      end

      it "scopes the collection to sent invitations" do
        expect(subject.data[:sent_invitations]).not_to include(invitation3)
      end
    end

    context "relevant_organisations" do
      let!(:configuration_with_no_invitations_formats) { create(:configuration, invitation_formats: []) }
      let!(:organisation_with_no_invitations_formats) do
        create(:organisation, department: department, configurations: [configuration_with_no_invitations_formats])
      end

      it "scopes the collection to the department" do
        expect(subject.data[:relevant_organisations]).to include(organisation)
        expect(subject.data[:relevant_organisations]).not_to include(other_organisation)
      end

      it "scopes the collection to the ones with an active configuration" do
        expect(subject.data[:relevant_organisations]).not_to include(organisation_with_no_invitations_formats)
        expect(subject.data[:relevant_organisations]).not_to include(organisation_with_no_configuration)
      end
    end

    context "relevant_applicants" do
      let!(:applicant3) do
        create(:applicant, department: department, organisations: [organisation], deleted_at: Time.zone.today)
      end
      let!(:applicant4) do
        create(:applicant, department: department, organisations: [organisation], archived_at: Time.zone.today)
      end
      let!(:applicant5) do
        create(:applicant, department: department, organisations: [organisation_with_no_configuration])
      end

      it "scopes the collection to the department" do
        expect(subject.data[:relevant_applicants]).to include(applicant1)
        expect(subject.data[:relevant_applicants]).not_to include(applicant2)
      end

      it "does not include the deleted applicants" do
        expect(subject.data[:relevant_applicants]).not_to include(applicant3)
      end

      it "does not include the archived applicants" do
        expect(subject.data[:relevant_applicants]).not_to include(applicant4)
      end

      it "does not include the applicant from irrelevant organisations" do
        expect(subject.data[:relevant_applicants]).not_to include(applicant5)
      end
    end

    context "relevant_agents" do
      let!(:agent3) { create(:agent, organisations: [organisation], has_logged_in: true, email: "pierre@beta.gouv.fr") }
      let!(:agent4) { create(:agent, organisations: [organisation], has_logged_in: false) }

      it "scopes the collection to the department" do
        expect(subject.data[:relevant_agents]).to include(agent1)
        expect(subject.data[:relevant_agents]).not_to include(agent2)
      end

      it "does not include the betagouv agents" do
        expect(subject.data[:relevant_agents]).not_to include(agent3)
      end

      it "does not include the agents who never logged in" do
        expect(subject.data[:relevant_agents]).not_to include(agent4)
      end
    end

    context "relevant_rdv_contexts" do
      let!(:applicant3) { create(:applicant, department: department, organisations: [organisation]) }
      let!(:rdv3) { create(:rdv, organisation: organisation) }
      let!(:participation3) { create(:participation, rdv: rdv3) }
      let!(:rdv_context3) { create(:rdv_context, applicant: applicant3, participations: [participation3]) }
      let!(:applicant4) { create(:applicant, department: department, organisations: [organisation]) }
      let!(:invitation4) { create(:invitation) }
      let!(:rdv4) { create(:rdv, organisation: organisation) }
      let!(:participation4) { create(:participation, rdv: rdv4) }
      let!(:rdv_context4) do
        create(:rdv_context, applicant: applicant4, invitations: [invitation4], participations: [participation4])
      end
      let!(:applicant5) { create(:applicant, department: department, organisations: [organisation]) }
      let!(:invitation5) { create(:invitation) }
      let!(:rdv_context5) do
        create(:rdv_context, applicant: applicant5, invitations: [invitation5])
      end
      let!(:applicant6) do
        create(:applicant, department: department, organisations: [organisation_with_no_configuration])
      end
      let!(:invitation6) { create(:invitation, sent_at: Time.zone.today) }
      let!(:rdv6) { create(:rdv, organisation: organisation) }
      let!(:participation6) { create(:participation, rdv: rdv6) }
      let!(:rdv_context6) do
        create(:rdv_context, applicant: applicant6, invitations: [invitation6], participations: [participation6])
      end

      it "scopes the collection to the department" do
        expect(subject.data[:relevant_rdv_contexts]).to include(rdv_context1)
        expect(subject.data[:relevant_rdv_contexts]).not_to include(rdv_context2)
      end

      it "does not include rdv_contexts with no invitations" do
        expect(subject.data[:relevant_rdv_contexts]).not_to include(rdv_context3)
      end

      it "does not include rdv_contexts with unsent invitations" do
        expect(subject.data[:relevant_rdv_contexts]).not_to include(rdv_context4)
      end

      it "does not include rdv_contexts with no rdvs" do
        expect(subject.data[:relevant_rdv_contexts]).not_to include(rdv_context5)
      end

      it "does not include rdv_contexts of irrelevant applicants" do
        expect(subject.data[:relevant_rdv_contexts]).not_to include(rdv_context6)
      end
    end

    context "relevant_rdvs" do
      let!(:applicant3) do
        create(:applicant, department: department, organisations: [organisation_with_no_configuration])
      end
      let!(:rdv3) { create(:rdv, organisation: organisation_with_no_configuration) }
      let!(:participation3) { create(:participation, rdv: rdv3, applicant: applicant3) }

      it "scopes the collection to the department" do
        expect(subject.data[:relevant_rdvs]).to include(rdv1)
        expect(subject.data[:relevant_rdvs]).not_to include(rdv2)
      end

      it "does not include rdvs of irrelevant applicants" do
        expect(subject.data[:relevant_rdvs]).not_to include(rdv3)
      end
    end

    context "when the department_number is 'all'" do
      let!(:department_number) { "all" }

      context "all_applicants" do
        it "does not scope the collection to the department" do
          expect(subject.data[:all_applicants]).to include(applicant2)
        end
      end

      context "all_rdvs" do
        it "does not scope the collection to the department" do
          expect(subject.data[:all_rdvs]).to include(rdv2)
        end
      end

      context "sent_invitations" do
        it "does not scope the collection to the department" do
          expect(subject.data[:sent_invitations]).to include(invitation2)
        end
      end

      context "relevant_organisations" do
        it "does not scope the collection to the department" do
          expect(subject.data[:relevant_organisations]).to include(other_organisation)
        end
      end

      context "relevant_applicants" do
        it "does not scope the collection to the department" do
          expect(subject.data[:relevant_applicants]).to include(applicant2)
        end
      end

      context "relevant_agents" do
        it "does not scope the collection to the department" do
          expect(subject.data[:relevant_agents]).to include(agent1)
          expect(subject.data[:relevant_agents]).to include(agent2)
        end
      end

      context "relevant_rdv_contexts" do
        it "does not scope the collection to the department" do
          expect(subject.data[:relevant_rdv_contexts]).to include(rdv_context2)
        end
      end

      context "relevant_rdvs" do
        it "does not scope the collection to the department" do
          expect(subject.data[:relevant_rdvs]).to include(rdv2)
        end
      end
    end
  end
end
