describe ApplicantPolicy, type: :policy do
  subject { described_class }

  let!(:organisation) { create(:organisation) }
  let!(:organisation2) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "#show?" do
    context "when the agent belongs to a department organisation" do
      let!(:applicant) { create(:applicant, organisations: [organisation, organisation2]) }

      permissions(:show?) { it { is_expected.to permit(agent, applicant) } }
    end

    context "when the agent does not belong to all the department organisations" do
      let!(:applicant) { create(:applicant, organisations: [organisation2]) }

      permissions(:show?) { it { is_expected.not_to permit(agent, applicant) } }
    end

    context "when the applicant is deleted" do
      let!(:applicant) { create(:applicant, organisations: [organisation], status: "deleted") }

      permissions(:show?) { it { is_expected.not_to permit(agent, applicant) } }
    end
  end
end
