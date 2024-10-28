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
    let(:orientation) { build(:orientation, starts_at: Time.zone.today, ends_at: nil) }

    it { expect(orientation).to be_valid }
  end

  describe "time_range is not sufficient" do
    let(:orientation) { build(:orientation, starts_at: Time.zone.today, ends_at: Time.zone.tomorrow) }

    it "adds errors" do
      expect(orientation).not_to be_valid
      expect(orientation.errors.full_messages.to_sentence)
        .to include("La période doit être d'au moins une semaine")
    end
  end

  describe "ends_at after starts_at" do
    let(:orientation) { build(:orientation, starts_at: Date.parse("20/12/2022"), ends_at: Date.parse("11/11/2022")) }

    it "adds errors" do
      expect(orientation).not_to be_valid
      expect(orientation.errors.full_messages.to_sentence)
        .to include("La date de fin doit être postérieure à la date de début")
    end
  end
end
