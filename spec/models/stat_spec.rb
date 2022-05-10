describe Stat do
  subject do
    described_class.new(applicants: Applicant.all, agents: Agent.all, invitations: Invitation.all,
                        rdvs: Rdv.all, rdv_contexts: RdvContext.all, organisations: Organisation.all)
  end

  let!(:configuration) { create(:configuration, notify_applicant: false) }
  let!(:relevant_organisation) { create(:organisation, configurations: [configuration]) }
  let!(:configuration_notify) { create(:configuration, notify_applicant: true) }
  let!(:irrelevant_organisation) { create(:organisation, configurations: [configuration_notify]) }
  let!(:rdv_context_orientation) { create(:rdv_context, context: "rsa_orientation") }
  let!(:rdv_context_orientation_platform) { create(:rdv_context, context: "rsa_orientation_on_phone_platform") }
  let!(:rdv_context_accompagnement) { create(:rdv_context, context: "rsa_accompagnement") }
  let!(:relevant_applicant) { create(:applicant, organisations: [relevant_organisation]) }
  let!(:relevant_applicant2) { create(:applicant, organisations: [relevant_organisation, irrelevant_organisation]) }
  let!(:irrelevant_applicant) { create(:applicant, organisations: [irrelevant_organisation]) }

  describe "#relevant_organisations" do
    context "when an organisation notifies applicants" do
      it "is filtered" do
        expect(subject.relevant_organisations).to include(relevant_organisation)
        expect(subject.relevant_organisations).not_to include(irrelevant_organisation)
      end
    end
  end

  describe "#relevant_applicants" do
    context "when an applicant does not belong to a relevant organisation" do
      it "is filtered" do
        expect(subject.relevant_applicants).to include(relevant_applicant)
        expect(subject.relevant_applicants).to include(relevant_applicant2)
        expect(subject.relevant_applicants).not_to include(irrelevant_applicant)
      end
    end

    context "when an applicant is deleted or archived" do
      let!(:irrelevant_applicant) { create(:applicant, organisations: [relevant_organisation], status: "deleted") }
      let!(:irrelevant_applicant2) { create(:applicant, organisations: [relevant_organisation], is_archived: true) }

      it "is filtered" do
        expect(subject.relevant_applicants).to include(relevant_applicant)
        expect(subject.relevant_applicants).not_to include(irrelevant_applicant)
        expect(subject.relevant_applicants).not_to include(irrelevant_applicant2)
      end
    end
  end

  describe "#relevant_agents" do
    context "when an agent belongs to rdv-insertion" do
      let!(:relevant_agent) { create(:agent) }
      let!(:irrelevant_agent) { create(:agent, email: "quentin.blanc@beta.gouv.fr") }

      it "is filtered" do
        expect(subject.relevant_agents).to include(relevant_agent)
        expect(subject.relevant_agents).not_to include(irrelevant_agent)
      end
    end
  end

  describe "#relevant_rdvs" do
    context "when a rdv does not belong to a relevant applicant" do
      let!(:relevant_rdv) { create(:rdv) }
      let!(:irrelevant_rdv) { create(:rdv) }
      let!(:irrelevant_rdv2) { create(:rdv) }
      let!(:irrelevant_rdv3) { create(:rdv) }
      let!(:relevant_applicant) { create(:applicant, organisations: [relevant_organisation], rdvs: [relevant_rdv]) }
      let!(:irrelevant_applicant) do
        create(:applicant, organisations: [irrelevant_organisation], rdvs: [irrelevant_rdv])
      end
      let!(:irrelevant_applicant2) do
        create(:applicant, organisations: [relevant_organisation], status: "deleted", rdvs: [irrelevant_rdv2])
      end
      let!(:irrelevant_applicant3) do
        create(:applicant, organisations: [relevant_organisation], is_archived: true, rdvs: [irrelevant_rdv3])
      end

      it "is filtered" do
        expect(subject.relevant_rdvs).to include(relevant_rdv)
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv)
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv2)
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv3)
      end
    end
  end

  describe "#orientation_rdvs" do
    context "when a rdv does not belong to a rsa_orientation rdv_context" do
      let!(:relevant_rdv) { create(:rdv, rdv_contexts: [rdv_context_orientation]) }
      let!(:irrelevant_rdv) { create(:rdv, rdv_contexts: [rdv_context_orientation_platform]) }
      let!(:irrelevant_rdv2) { create(:rdv, rdv_contexts: [rdv_context_accompagnement]) }

      it "is filtered" do
        relevant_rdv.applicants = [relevant_applicant]
        irrelevant_rdv.applicants = [relevant_applicant]
        irrelevant_rdv2.applicants = [relevant_applicant]
        expect(subject.orientation_rdvs).to include(relevant_rdv)
        expect(subject.orientation_rdvs).not_to include(irrelevant_rdv)
        expect(subject.orientation_rdvs).not_to include(irrelevant_rdv2)
      end
    end
  end
end
