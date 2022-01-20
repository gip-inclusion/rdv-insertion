describe InvitationPolicy, type: :policy do
  subject { described_class }

  let!(:organisation) { create(:organisation) }
  let!(:organisation2) { create(:organisation) }
  let!(:invitation) { create(:invitation, applicant: applicant) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "#create?" do
    let!(:applicant) { create(:applicant, organisations: [organisation, organisation2]) }

    context "when the agent belongs to the applicant organisation" do
      permissions(:create?) { it { is_expected.to permit(agent, invitation) } }
    end

    context "when the agent does not belong to the applicant organisation" do
      let!(:applicant) { create(:applicant, organisations: [organisation2]) }

      permissions(:create?) { it { is_expected.not_to permit(agent, invitation) } }
    end
  end
end
