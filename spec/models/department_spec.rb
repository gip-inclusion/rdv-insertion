describe Department do
  describe "department rdv_solidarites_organisation_id uniqueness validation" do
    context "no collision" do
      let(:department) { build(:department, rdv_solidarites_organisation_id: 1) }

      it { expect(department).to be_valid }
    end

    context "blank rdv_solidarites_organisation_id" do
      let!(:department_existing) { create(:department, rdv_solidarites_organisation_id: 1) }

      let(:department) { build(:department, rdv_solidarites_organisation_id: "") }

      it { expect(department).to be_valid }
    end

    context "colliding rdv_solidarites_organisation_id" do
      let!(:department_existing) { create(:department, rdv_solidarites_organisation_id: 1) }
      let(:department) { build(:department, rdv_solidarites_organisation_id: 1) }

      it "adds errors" do
        expect(department).not_to be_valid
        expect(department.errors.details).to eq({ rdv_solidarites_organisation_id: [{ error: :taken, value: 1 }] })
        expect(department.errors.full_messages.to_sentence)
          .to include("Rdv solidarites organisation est déjà utilisé")
      end
    end
  end
end
