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
          .to include("Rdv solidarites user has already been taken")
      end
    end
  end

  describe "uid uniqueness and presence" do
    context "no collision" do
      let(:applicant) { build(:applicant, uid: '123') }

      it { expect(applicant).to be_valid }
    end

    context "blank uid" do
      let(:applicant) { build(:applicant, uid: "") }

      it 'adds error' do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ uid: [{ error: :blank }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Uid can't be blank")
      end
    end

    context "colliding rdv_solidarites_user_id" do
      let!(:applicant_existing) { create(:applicant, uid: '123') }
      let(:applicant) { build(:applicant, uid: '123') }

      it "adds errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ uid: [{ error: :taken, value: '123' }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Uid has already been taken")
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
        phone_number_formatted: "+33110101010",
        affiliation_number: "1111"
      )
    end
    let!(:applicant_cecile) do
      create(
        :applicant,
        first_name: "cecile",
        last_name: "defrance",
        email: "cecile@defrance.fr",
        phone_number_formatted: nil,
        affiliation_number: "1111"
      )
    end
    let!(:applicant_romain) do
      create(
        :applicant,
        first_name: "romain",
        last_name: "duris",
        email: "romain@duris.fr",
        phone_number_formatted: "+33782605941",
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
end
