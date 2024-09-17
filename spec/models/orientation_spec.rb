describe Orientation do
  describe "orientation starts_at uniqueness validation" do
    let!(:user) { create(:user) }
    let(:orientation) { build(:orientation, starts_at: Date.parse("20/12/2022"), user:) }

    context "no collision" do
      it { expect(orientation).to be_valid }
    end

    context "colliding starts_at with another user" do
      let!(:other_orientation) { create(:orientation, starts_at: Date.parse("20/12/2022")) }

      it { expect(orientation).to be_valid }
    end

    context "colliding starts_at with same user" do
      let!(:other_orientation) { create(:orientation, starts_at: Date.parse("20/12/2022"), user:) }

      it "adds errors" do
        expect(orientation).not_to be_valid
        expect(orientation.errors.full_messages.to_sentence)
          .to include("Date de début est déjà utilisé")
      end
    end
  end

  describe "starts_at is in the future" do
    let(:orientation) { build(:orientation, starts_at: Date.tomorrow) }

    it "adds errors" do
      expect(orientation).not_to be_valid
      expect(orientation.errors.full_messages.to_sentence)
        .to include("la date de début doit être antérieure ou égale à la date d'aujourd'hui")
    end
  end

  describe "starts_at is today" do
    let(:orientation) { build(:orientation, starts_at: Time.zone.today) }

    it { expect(orientation).to be_valid }
  end

  describe "ends_at after starts_at" do
    let(:orientation) { build(:orientation, starts_at: Date.parse("20/12/2022"), ends_at: Date.parse("11/11/2022")) }

    it "adds errors" do
      expect(orientation).not_to be_valid
      expect(orientation.errors.full_messages.to_sentence)
        .to include("La date de fin doit être postérieure à la date de début")
    end
  end

  describe ".relevant_for_organisations" do
    subject { described_class.relevant_for_organisations([organisation]) }

    let!(:organisation) { create(:organisation) }

    let!(:valid_user) { create(:user, organisations: [organisation]) }
    let!(:not_in_org_user) { create(:user) }
    let!(:deleted_user) { create(:user, organisations: [organisation], deleted_at: Time.zone.now) }

    let!(:valid_orientation) { create(:orientation, organisation: organisation, user: valid_user) }
    let!(:invalid_orientation) { create(:orientation, organisation: organisation, user: not_in_org_user) }
    let!(:invalid_orientation2) { create(:orientation, organisation: organisation, user: deleted_user) }

    it "returns orientations only for active users of the organisation" do
      expect(subject).to include(valid_orientation)
      expect(subject).not_to include(invalid_orientation)
      expect(subject).not_to include(invalid_orientation2)
    end
  end
end
