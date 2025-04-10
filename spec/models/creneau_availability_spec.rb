RSpec.describe CreneauAvailability, type: :model do
  describe "scopes" do
    describe ".with_pending_invitations" do
      let!(:creneau_with_nil_invitations) { create(:creneau_availability, number_of_pending_invitations: nil) }
      let!(:creneau_with_zero_invitations) { create(:creneau_availability, number_of_pending_invitations: 0) }
      let!(:creneau_with_invitations) { create(:creneau_availability, number_of_pending_invitations: 5) }

      it "returns only records with pending invitations (not nil or 0)" do
        result = described_class.with_pending_invitations

        expect(result).to include(creneau_with_invitations)
        expect(result).not_to include(creneau_with_nil_invitations)
        expect(result).not_to include(creneau_with_zero_invitations)
      end
    end

    describe ".lacking_availability" do
      let!(:creneau_with_no_invitations) { create(:creneau_availability, number_of_pending_invitations: nil) }
      let!(:creneau_with_excess_availability) do
        create(:creneau_availability, number_of_creneaux_available: 20, number_of_pending_invitations: 5)
      end
      let!(:creneau_with_insufficient_availability) do
        create(:creneau_availability, number_of_creneaux_available: 5, number_of_pending_invitations: 10)
      end
      let!(:creneau_with_borderline_availability) do
        create(:creneau_availability, number_of_creneaux_available: 15, number_of_pending_invitations: 8)
      end

      it "returns only records where availability is insufficient or borderline" do
        result = described_class.lacking_availability

        expect(result).to include(creneau_with_insufficient_availability)
        expect(result).to include(creneau_with_borderline_availability)
        expect(result).not_to include(creneau_with_excess_availability)
        expect(result).not_to include(creneau_with_no_invitations)
      end
    end
  end

  describe "#seriousness" do
    context "when number_of_creneaux_available > 190" do
      let(:creneau) do
        build(:creneau_availability, number_of_creneaux_available: 200, number_of_pending_invitations: 5)
      end

      it "returns 'info'" do
        expect(creneau.seriousness).to eq("info")
      end
    end

    context "when diff between available and pending is negative" do
      let(:creneau) { build(:creneau_availability, number_of_creneaux_available: 5, number_of_pending_invitations: 10) }

      it "returns 'danger'" do
        expect(creneau.seriousness).to eq("danger")
      end
    end

    context "when diff between available and pending is less than 10" do
      let(:creneau) { build(:creneau_availability, number_of_creneaux_available: 15, number_of_pending_invitations: 8) }

      it "returns 'warning'" do
        expect(creneau.seriousness).to eq("warning")
      end
    end

    context "when diff between available and pending is 10 or more" do
      let(:creneau) { build(:creneau_availability, number_of_creneaux_available: 20, number_of_pending_invitations: 5) }

      it "returns 'info'" do
        expect(creneau.seriousness).to eq("info")
      end
    end
  end
end
