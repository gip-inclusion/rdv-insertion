describe Organisation do
  describe "organisation rdv_solidarites_organisation_id uniqueness validation" do
    context "no collision" do
      let(:organisation) { build(:organisation, rdv_solidarites_organisation_id: 1) }

      it { expect(organisation).to be_valid }
    end

    context "blank rdv_solidarites_organisation_id" do
      let!(:organisation_existing) { create(:organisation, rdv_solidarites_organisation_id: 1) }

      let(:organisation) { build(:organisation, rdv_solidarites_organisation_id: "") }

      it { expect(organisation).to be_valid }
    end

    context "colliding rdv_solidarites_organisation_id" do
      let!(:organisation_existing) { create(:organisation, rdv_solidarites_organisation_id: 1) }
      let(:organisation) { build(:organisation, rdv_solidarites_organisation_id: 1) }

      it "adds errors" do
        expect(organisation).not_to be_valid
        expect(organisation.errors.details).to eq({ rdv_solidarites_organisation_id: [{ error: :taken, value: 1 }] })
        expect(organisation.errors.full_messages.to_sentence)
          .to include("Rdv solidarites organisation est déjà utilisé")
      end
    end
  end
end
