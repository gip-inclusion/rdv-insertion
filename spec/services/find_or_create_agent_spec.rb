describe FindOrCreateAgent, type: :service do
  subject { described_class.call(email: agent.email, organisation_ids: organisation_ids) }

  let!(:agent) { create(:agent) }
  let!(:email) { agent.email }

  let!(:organisation_ids) { [] }

  describe "#call" do
    let(:error_message) { "l'agent n'appartient pas à une organisation liée à un département" }

    context "when no organisation_ids are passed" do
      let!(:organisation_ids) { [] }

      it "fails with an error" do
        expect(subject.failure?).to eq(true)
        expect(subject.success?).to eq(false)
        expect(subject.errors).to eq([error_message])
      end
    end

    context "when the organisations does not belong to one department" do
      let!(:department) { create(:department, rdv_solidarites_organisation_id: 31) }
      let!(:organisation_ids) { [39, 52] }

      it "fails with an error" do
        expect(subject.failure?).to eq(true)
        expect(subject.success?).to eq(false)
        expect(subject.errors).to eq([error_message])
      end
    end

    context "when department is found" do
      let!(:department) { create(:department, rdv_solidarites_organisation_id: 31) }
      let!(:organisation_ids) { [31, 42] }

      before do
        allow(Agent).to receive(:find_or_create_by)
          .with(email: email)
          .and_return(agent)
      end

      it "is a success" do
        expect(subject.success?).to eq(true)
      end

      it "finds or create the agent" do
        expect(Agent).to receive(:find_or_create_by)
          .with(email: email)
        subject
      end

      it "returns the agent" do
        expect(subject.agent).to eq(agent)
      end

      it "updates the agent by assigning the departments" do
        subject
        expect(agent.departments).to eq([department])
      end
    end
  end
end
