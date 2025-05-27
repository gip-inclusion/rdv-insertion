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

    describe ".with_rsa_related_motif" do
      let!(:rsa_motif_category) { create(:motif_category, motif_category_type: "rsa_orientation") }
      let!(:non_rsa_motif_category) { create(:motif_category, motif_category_type: "autre") }

      let!(:rsa_category_config) { create(:category_configuration, motif_category: rsa_motif_category) }
      let!(:non_rsa_category_config) { create(:category_configuration, motif_category: non_rsa_motif_category) }

      let!(:rsa_creneau) { create(:creneau_availability, category_configuration: rsa_category_config) }
      let!(:non_rsa_creneau) { create(:creneau_availability, category_configuration: non_rsa_category_config) }

      it "returns only records with RSA-related motif categories" do
        result = described_class.with_rsa_related_motif

        expect(result).to include(rsa_creneau)
        expect(result).not_to include(non_rsa_creneau)
      end
    end
  end

  describe "#availability_level" do
    context "when number_of_creneaux_available > 190" do
      let(:creneau) do
        build(:creneau_availability, number_of_creneaux_available: 200, number_of_pending_invitations: 5)
      end

      it "returns 'info'" do
        expect(creneau.availability_level).to eq("info")
      end
    end

    context "when diff between available and pending is negative" do
      let(:creneau) { build(:creneau_availability, number_of_creneaux_available: 5, number_of_pending_invitations: 10) }

      it "returns 'danger'" do
        expect(creneau.availability_level).to eq("danger")
      end
    end

    context "when diff between available and pending is less than 10" do
      let(:creneau) { build(:creneau_availability, number_of_creneaux_available: 15, number_of_pending_invitations: 8) }

      it "returns 'warning'" do
        expect(creneau.availability_level).to eq("warning")
      end
    end

    context "when diff between available and pending is 10 or more" do
      let(:creneau) { build(:creneau_availability, number_of_creneaux_available: 20, number_of_pending_invitations: 5) }

      it "returns 'info'" do
        expect(creneau.availability_level).to eq("info")
      end
    end
  end
end
