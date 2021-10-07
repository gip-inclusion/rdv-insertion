describe Rdv do
  describe "rdv rdv_solidarites_rdv_id uniqueness validation" do
    context "no collision" do
      let(:rdv) { build(:rdv, rdv_solidarites_rdv_id: 1) }

      it { expect(rdv).to be_valid }
    end

    context "blank rdv_solidarites_rdv_id" do
      let(:rdv) { build(:rdv, rdv_solidarites_rdv_id: "") }

      it "adds errors" do
        expect(rdv).not_to be_valid
        expect(rdv.errors.details).to eq({ rdv_solidarites_rdv_id: [{ error: :blank }] })
        expect(rdv.errors.full_messages.to_sentence)
          .to include("Rdv solidarites rdv doit être rempli(e)")
      end
    end

    context "colliding rdv_solidarites_rdv_id" do
      let!(:rdv_existing) { create(:rdv, rdv_solidarites_rdv_id: 1) }
      let(:rdv) { build(:rdv, rdv_solidarites_rdv_id: 1) }

      it "adds errors" do
        expect(rdv).not_to be_valid
        expect(rdv.errors.details).to eq({ rdv_solidarites_rdv_id: [{ error: :taken, value: 1 }] })
        expect(rdv.errors.full_messages.to_sentence)
          .to include("Rdv solidarites rdv est déjà utilisé")
      end
    end
  end
end
