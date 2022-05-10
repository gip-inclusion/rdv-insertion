describe Stat do
  subject do
    described_class.new(applicants: Applicant.all, agents: Agent.all, invitations: Invitation.all,
                        rdvs: Rdv.all, rdv_contexts: RdvContext.all, organisations: Organisation.all)
  end

  let!(:configuration) { create(:configuration, notify_applicant: false) }
  let!(:organisation) { create(:organisation, configurations: [configuration]) }
  let!(:configuration_notify) { create(:configuration, notify_applicant: true) }
  let!(:organisation2) { create(:organisation, configurations: [configuration_notify]) }
  let!(:applicant) { create(:applicant, organisations: [organisation]) }
  let!(:applicant2) { create(:applicant, organisations: [organisation]) }
  let!(:applicant3) { create(:applicant, organisations: [organisation, organisation2]) }
  let!(:applicant4) { create(:applicant, organisations: [organisation2]) }

  describe "organisations are correctly filtered" do
    context "notify organisations are not included" do
      it { expect(subject.relevant_organisations).to eq([organisation]) }
    end
  end

  describe "applicants are correctly filtered" do
    context "by organisation" do

      it { expect(subject.relevant_applicants).to eq([applicant, applicant2, applicant3]) }
    end

    context "by status" do
      let!(:applicant) { create(:applicant, organisations: [organisation]) }
      let!(:applicant2) { create(:applicant, organisations: [organisation], status: "deleted") }
      let!(:applicant3) { create(:applicant, organisations: [organisation], is_archived: true) }

      it { expect(subject.relevant_applicants).to eq([applicant]) }
    end
  end

  describe "agents are correctly filtered" do
    context "rdv-insertion team is not included" do
      let!(:agent) { create(:agent) }
      let!(:agent2) { create(:agent, email: "quentin.blanc@beta.gouv.fr") }

      it { expect(subject.relevant_agents).to eq([agent]) }
    end
  end

  describe "rdvs are correctly filtered" do
    context "by applicants" do
      let!(:rdv) { create(:rdv, applicants: [applicant]) }
      let!(:rdv2) { create(:rdv, applicants: [applicant2]) }
      let!(:rdv3) { create(:rdv, applicants: [applicant3]) }
      let!(:rdv4) { create(:rdv, applicants: [applicant4]) }

      it { expect(subject.relevant_rdvs).to eq([rdv, rdv2, rdv3]) }
    end
  end
end
