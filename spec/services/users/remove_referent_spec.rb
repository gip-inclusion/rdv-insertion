describe Users::RemoveReferent, type: :service do
  subject do
    described_class.call(agent:, user:)
  end

  let!(:agent) { create(:agent) }
  let!(:user) { create(:user, referents: [agent]) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::DeleteReferentAssignation).to receive(:call)
        .with(
          rdv_solidarites_user_id: user.rdv_solidarites_user_id,
          rdv_solidarites_agent_id: agent.rdv_solidarites_agent_id
        ).and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "removes the agent from the user" do
      subject
      expect(user.reload.referents).to eq([])
    end

    context "when it fails to remove referent through API" do
      before do
        allow(RdvSolidaritesApi::DeleteReferentAssignation).to receive(:call)
          .with(
            rdv_solidarites_user_id: user.rdv_solidarites_user_id,
            rdv_solidarites_agent_id: agent.rdv_solidarites_agent_id
          ).and_return(OpenStruct.new(success?: false, errors: ["impossible to remove"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "does not remove the agent to the user" do
        subject
        expect(user.reload.referents).to include(agent)
      end

      it "outputs an error" do
        expect(subject.errors).to eq(["impossible to remove"])
      end
    end
  end
end
