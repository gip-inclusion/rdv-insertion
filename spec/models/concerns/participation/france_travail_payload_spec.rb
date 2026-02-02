describe Participation::FranceTravailPayload, type: :concern do
  let(:payload) { participation.to_ft_payload }
  let(:organisation) { create(:organisation, organisation_type: "conseil_departemental") }
  let(:user) { create(:user, organisations: [organisation]) }
  let(:follow_up) { create(:follow_up, user: user) }
  let(:motif) { create(:motif, motif_category:) }
  let(:motif_category) { create(:motif_category, motif_category_type: "rsa_orientation") }
  let(:rdv) { create(:rdv, organisation: organisation, motif: motif) }
  let(:participation) { create(:participation, follow_up:, user:, rdv:, status: "unknown") }

  describe "#to_ft_payload" do
    it "returns the correct payload structure" do
      expect(payload).to include(
        id: participation.france_travail_id,
        date: participation.starts_at.to_datetime,
        duree: participation.duration_in_min,
        theme: participation.motif.motif_category.name
      )
    end
  end

  describe "france_travail_modalite" do
    context "when participation is by phone" do
      before { motif.update(location_type: "phone") }

      it "returns TELEPHONE" do
        expect(payload[:modaliteContact]).to eq("TELEPHONE")
      end
    end

    context "when participation is not by phone" do
      it "returns PHYSIQUE" do
        expect(payload[:modaliteContact]).to eq("PHYSIQUE")
      end
    end
  end

  describe "france_travail_initiateur" do
    context "when participation is created by user" do
      it "returns USAGER" do
        expect(payload[:initiateur]).to eq("USAGER")
      end
    end

    context "when participation is not created by user" do
      before { participation.update(created_by_type: "agent") }

      it "returns PARTENAIRE" do
        expect(payload[:initiateur]).to eq("PARTENAIRE")
      end
    end
  end

  describe "france_travail_motif" do
    context "when motif category name is a first accompaniement rdv" do
      before { motif_category.update!(short_name: "rsa_premier_rdv_daccompagnement") }

      it "returns ACC" do
        expect(payload[:motif]).to eq("ACC")
      end
    end

    context "when participation motif category is rsa_orientation" do
      it "returns ORI" do
        expect(payload[:motif]).to eq("ORI")
      end
    end

    context "when participation motif category is rsa_accompagnement but not first accompaniement rdv" do
      before { motif_category.update!(motif_category_type: "rsa_accompagnement", name: "RSA Accompagnement") }

      it "returns AUT" do
        expect(payload[:motif]).to eq("AUT")
      end
    end

    context "when participation motif category is neither rsa_orientation nor first accompaniement rdv" do
      before { motif_category.update!(motif_category_type: "autre", name: "Autre catégorie") }

      it "returns AUT" do
        expect(payload[:motif]).to eq("AUT")
      end
    end
  end

  describe "france_travail_organisme_code" do
    {
      "conseil_departemental" => "CD",
      "france_travail" => "FT",
      "delegataire_rsa" => "DCD",
      "autre" => "IND"
    }.each do |organisation_type, expected|
      context "when participation organisation type is #{organisation_type}" do
        before { organisation.update(organisation_type: organisation_type) }

        it "returns #{expected}" do
          expect(payload[:organisme][:code]).to eq(expected)
        end
      end
    end
  end

  describe "france_travail_type_reception" do
    context "when participation is collectif" do
      before { motif.update(collectif: true) }

      it "returns COL" do
        expect(payload[:typeReception]).to eq("COL")
      end
    end

    context "when participation is not collectif" do
      it "returns IND" do
        expect(payload[:typeReception]).to eq("IND")
      end
    end
  end

  describe "france_travail_statut" do
    {
      "seen" => "EFFECTUE",
      "excused" => "ANNULE",
      "revoked" => "ANNULE",
      "noshow" => "ABSENT",
      "unknown" => "PRIS"
    }.each do |status, expected|
      context "when status is #{status}" do
        before { participation.update(status: status) }

        it "returns #{expected}" do
          expect(payload[:statut]).to eq(expected)
        end
      end
    end
  end
end
