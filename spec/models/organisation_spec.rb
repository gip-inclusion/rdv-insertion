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
          .to include("ID de l'organisation dans RDV-Solidarités est déjà utilisé")
      end
    end
  end

  describe "email validation" do
    context "email is valid" do
      let(:organisation) { build(:organisation, email: "some@test.fr") }

      it { expect(organisation).to be_valid }
    end

    context "email is invalid" do
      let(:organisation) { build(:organisation, email: "unvalid-email") }

      it "adds errors" do
        expect(organisation).not_to be_valid
        expect(organisation.errors.full_messages.to_sentence)
          .to include("Email n'est pas valide")
      end
    end
  end

  describe "phone_number validation" do
    context "phone_number is valid" do
      let(:organisation) { build(:organisation, phone_number: "0602030102") }

      it { expect(organisation).to be_valid }
    end

    context "4 digits numbers are valids for organisations" do
      let(:organisation) { build(:organisation, phone_number: "3949") }

      it { expect(organisation).to be_valid }
    end

    context "phone_number is invalid" do
      let(:organisation) { build(:organisation, phone_number: "12345") }

      it "adds errors" do
        expect(organisation).not_to be_valid
        expect(organisation.errors.full_messages.to_sentence)
          .to include("Numéro de téléphone n'est pas valide")
      end
    end
  end

  describe "archivable" do
    let(:organisation) { create(:organisation, agents: [create(:agent)]) }

    it "cannot be archived if agents are present" do
      organisation.update(archived_at: Time.current)
      expect(organisation).not_to be_valid
      expect(organisation.errors.full_messages.to_sentence)
        .to include("Ne peut pas être archivée si des agents sont présents")
    end
  end
end
