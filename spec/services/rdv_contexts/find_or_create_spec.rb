describe RdvContexts::FindOrCreate, type: :service do
  subject { described_class.call(user:, motif_category:) }

  let!(:organisation) { create(:organisation) }
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: motif_category) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:motif_category) { create(:motif_category) }
  let!(:rdv_context) { nil }

  before { allow(Current).to receive(:agent).and_return(agent) }

  describe "#call" do
    context "when the rdv context already exists" do
      let!(:rdv_context) { create(:rdv_context, user:, motif_category:) }

      it "is a success" do
        is_a_success
      end

      it "returns the rdv context" do
        expect(subject.rdv_context).to eq(rdv_context)
      end
    end

    context "when the rdv context does not exist" do
      it "is a success" do
        is_a_success
      end

      it "creates the rdv context" do
        expect { subject }.to change(RdvContext, :count).by(1)
      end

      it "returns the rdv context" do
        expect(subject.rdv_context).to eq(RdvContext.last)
      end
    end

    context "when the user does not belong to an organisation with this motif category" do
      let!(:organisation) { create(:organisation, configurations: [configuration]) }
      let!(:configuration) { create(:configuration, motif_category: other_motif_category) }
      let!(:other_motif_category) { create(:motif_category, short_name: "rsa_accompagnement") }

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(
          ["L'utilisateur n'appartient à aucune organisation gérant cette catégorie de motifs"]
        )
      end
    end

    context "when the agent is not authorized to create a rdv context" do
      let!(:agent) { create(:agent) }

      it "raises Pundit::NotAuthorizedError" do
        expect { subject }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end
end
