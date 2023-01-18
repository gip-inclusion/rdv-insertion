describe Applicant do
  describe "rdv_solidarites_user_id uniqueness validation" do
    context "no collision" do
      let(:applicant) { build(:applicant, rdv_solidarites_user_id: 1) }

      it { expect(applicant).to be_valid }
    end

    context "blank rdv_solidarites_user_id" do
      let!(:applicant_existing) { create(:applicant, rdv_solidarites_user_id: 1) }

      let(:applicant) { build(:applicant, rdv_solidarites_user_id: "") }

      it { expect(applicant).to be_valid }
    end

    context "colliding rdv_solidarites_user_id" do
      let!(:applicant_existing) { create(:applicant, rdv_solidarites_user_id: 1) }
      let(:applicant) { build(:applicant, rdv_solidarites_user_id: 1) }

      it "adds errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ rdv_solidarites_user_id: [{ error: :taken, value: 1 }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Rdv solidarites user est déjà utilisé")
      end
    end
  end

  describe "uid uniqueness" do
    context "no collision" do
      let(:applicant) { build(:applicant, uid: "123") }

      it { expect(applicant).to be_valid }
    end

    context "colliding uid" do
      let!(:applicant_existing) { create(:applicant) }
      let!(:applicant) { build(:applicant, uid: "123") }

      before do
        # we skip the callbacks not to recompute uid
        applicant_existing.update_columns(uid: "123")
      end

      it "adds errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ uid: [{ error: :taken, value: "123" }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Le couple numéro d'allocataire + rôle est déjà utilisé")
      end
    end
  end

  describe "department internal id uniqueness" do
    context "no collision" do
      let(:applicant) { build(:applicant, department_internal_id: "123") }

      it { expect(applicant).to be_valid }
    end

    context "colliding department internal id" do
      let!(:department) { create(:department) }
      let!(:applicant_existing) do
        create(:applicant, department: department, department_internal_id: "921", role: "demandeur")
      end
      let!(:applicant) do
        build(:applicant, department: department, department_internal_id: "921", role: "conjoint")
      end

      it "adds errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ department_internal_id: [{ error: :taken, value: "921" }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("ID interne au département est déjà utilisé")
      end
    end
  end

  describe "#search_by_text" do
    subject { described_class.search_by_text(query) }

    let!(:applicant_jean) do
      create(
        :applicant,
        first_name: "jean",
        last_name: "dujardin",
        email: "jean@dujardin.fr",
        phone_number: "+33110101010",
        affiliation_number: "1111"
      )
    end
    let!(:applicant_cecile) do
      create(
        :applicant,
        first_name: "cecile",
        last_name: "defrance",
        email: "cecile@defrance.fr",
        phone_number: nil,
        affiliation_number: "1111"
      )
    end
    let!(:applicant_romain) do
      create(
        :applicant,
        first_name: "romain",
        last_name: "duris",
        email: "romain@duris.fr",
        phone_number: "+33782605941",
        affiliation_number: "0000"
      )
    end

    context "name query" do
      let(:query) { "cecile" }

      it { is_expected.to include(applicant_cecile) }
      it { is_expected.not_to include(applicant_jean) }
      it { is_expected.not_to include(applicant_romain) }
    end

    context "email query" do
      let(:query) { "romain@duris" }

      it { is_expected.to include(applicant_romain) }
      it { is_expected.not_to include(applicant_cecile) }
      it { is_expected.not_to include(applicant_jean) }
    end

    context "phone number query" do
      let(:query) { "+3378" }

      it { is_expected.to include(applicant_romain) }
      it { is_expected.not_to include(applicant_cecile) }
      it { is_expected.not_to include(applicant_jean) }
    end

    context "affiliation number query" do
      let(:query) { "1111" }

      it { is_expected.to include(applicant_jean) }
      it { is_expected.to include(applicant_cecile) }
      it { is_expected.not_to include(applicant_romain) }
    end
  end

  describe "email format validation" do
    context "valid email format" do
      let(:applicant) { build(:applicant, email: "abc@test.fr") }

      it { expect(applicant).to be_valid }
    end

    context "nil email" do
      let(:applicant) { build(:applicant, email: nil) }

      it { expect(applicant).to be_valid }
    end

    context "wrong email format" do
      let(:applicant) { build(:applicant, email: "abc") }

      it "add errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ email: [{ error: :invalid, value: "abc" }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Email n'est pas valide")
      end
    end
  end

  describe "phone format validation" do
    context "valid phone format" do
      let(:applicant) { build(:applicant, phone_number: "0123456789") }

      it { expect(applicant).to be_valid }
    end

    context "nil phone" do
      let(:applicant) { build(:applicant, phone_number: nil) }

      it { expect(applicant).to be_valid }
    end

    context "wrong phone format" do
      let(:applicant) { build(:applicant, phone_number: "01234") }

      it "add errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ phone_number: [{ error: :invalid }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Téléphone n'est pas valide")
      end
    end
  end

  describe "uid or department_internal_id presence" do
    context "when an affiliation_number and a role is present" do
      let(:applicant) { build(:applicant, role: "demandeur", affiliation_number: "KOKO", department_internal_id: nil) }

      it { expect(applicant).to be_valid }
    end

    context "when a department_internal_id is present" do
      let(:applicant) { build(:applicant, role: nil, affiliation_number: nil, department_internal_id: "32424") }

      it { expect(applicant).to be_valid }
    end

    context "when no affiliation_number and no department_internal_id is present" do
      let(:applicant) { build(:applicant, role: nil, affiliation_number: nil, department_internal_id: nil) }

      it { expect(applicant).not_to be_valid }
    end
  end
end
