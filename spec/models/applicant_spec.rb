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
          .to include("Uid doit être rempli(e)")
      end
    end

    context "colliding rdv_solidarites_user_id" do
      let!(:applicant_existing) { create(:applicant, uid: '123') }
      let(:applicant) { build(:applicant, uid: '123') }

      it "adds errors" do
        expect(applicant).not_to be_valid
        expect(applicant.errors.details).to eq({ uid: [{ error: :taken, value: '123' }] })
        expect(applicant.errors.full_messages.to_sentence)
          .to include("Uid est déjà utilisé")
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

  describe "#set_status" do
    subject { applicant.set_status }

    context "without rdvs" do
      context "without invitations" do
        let!(:applicant) { create(:applicant, rdvs: [], invitations: []) }

        it "is not invited" do
          expect(subject).to eq(:not_invited)
        end
      end

      context "with no sent invitation" do
        let!(:invitation) { create(:invitation, sent_at: nil, applicant: applicant) }
        let!(:applicant) { create(:applicant, rdvs: []) }

        it "is not invited" do
          expect(subject).to eq(:not_invited)
        end
      end

      context "with sent invitation" do
        let!(:invitation) { create(:invitation, sent_at: Date.yesterday, applicant: applicant) }

        context "when invitation has not been accepted" do
          let!(:applicant) { create(:applicant, rdvs: [], invitation_accepted_at: nil) }

          it "is in invitation pending" do
            expect(subject).to eq(:invitation_pending)
          end
        end

        context "when invitation has been accepted" do
          let!(:applicant) { create(:applicant, rdvs: [], invitation_accepted_at: Date.yesterday) }

          it "is rdv creation pending" do
            expect(subject).to eq(:rdv_creation_pending)
          end
        end
      end
    end

    context "with rdvs" do
      context "with a seen rdv" do
        let!(:rdv) { create(:rdv, status: "seen") }
        let!(:rdv2) { create(:rdv, status: "noshow") }
        let!(:applicant) { create(:applicant, rdvs: [rdv, rdv2]) }

        it "is rdv seen" do
          expect(subject).to eq(:rdv_seen)
        end
      end

      context "with a pending rdv" do
        let!(:rdv) { create(:rdv, status: "unknown", starts_at: Time.zone.now + 3.days) }
        let!(:applicant) { create(:applicant, rdvs: [rdv]) }

        it "is rdv pending" do
          expect(subject).to eq(:rdv_pending)
        end
      end

      context "with last rdv cancelled" do
        let!(:rdv) { create(:rdv, status: "noshow") }
        let!(:applicant) { create(:applicant, rdvs: [rdv]) }

        it "is rdv pending" do
          expect(subject).to eq(:rdv_noshow)
        end
      end

      context "with a past rdv with status not updated" do
        let!(:rdv) { create(:rdv, status: "unknown", starts_at: Time.zone.now - 2.days) }
        let!(:applicant) { create(:applicant, rdvs: [rdv]) }

        it "is rdv pending" do
          expect(subject).to eq(:rdv_needs_status_update)
        end
      end
    end
  end
end
