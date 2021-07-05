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
end
