describe GenerateApplicantsCsv, type: :service do
  subject { described_class.call(applicants: applicants, structure: structure, motif_category: motif_category) }

  let!(:motif_category) { "rsa_orientation" }
  let!(:organisation) { create(:organisation, name: "Drome RSA") }
  let!(:structure) { organisation }
  let(:applicant1) { create(:applicant, last_name: "Dhobb", organisations: [organisation]) }
  let(:applicant2) { create(:applicant, last_name: "Casubolo", organisations: [organisation]) }
  let(:applicant3) { create(:applicant, last_name: "Blanc", organisations: [organisation]) }

  let!(:rdv) { create(:rdv, status: "unknown", starts_at: 2.days.ago) }
  let!(:invitation) { create(:invitation, applicant: applicant1, format: "email", sent_at: 3.days.ago) }
  let!(:rdv_context) { create(:rdv_context, rdvs: [rdv], invitations: [invitation], applicant: applicant1) }

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3]) }

  describe "#call" do
    context "it exports applicants to csv" do
      it "is a success" do
        expect(subject.success?).to eq(true)
      end

      context "it generates a filename" do
        context "structure is present" do
          it "generates a filename with structure" do
            expect(subject.filename).to eq("Liste_beneficiaires_rsa_orientation_organisation_drome_rsa.csv")
          end
        end

        context "structure is nil" do
          let!(:structure) { nil }

          it "generates a generic filename" do
            expect(subject.filename).to eq("Liste_beneficiaires.csv")
          end
        end
      end

      it "generates headers" do
        expect(subject.csv).to start_with("\uFEFFCivilité;Nom;Prénom;Numéro d'allocataire;ID interne au département;Em")
      end

      it "generates one line for each applicant required" do
        expect(subject.csv.scan(/(?=\n)/).count).to eq(applicants.count + 1)
      end

      it "includes the required applicants" do
        expect(subject.csv).to include("Dhobb")
        expect(subject.csv).to include("Casubolo")
        expect(subject.csv).to include("Blanc")
      end

      it "display the invitations dates" do
        expect(subject.csv).to include(invitation.sent_at&.strftime("%d/%m/%Y"))
      end

      it "display the rdvs dates" do
        expect(subject.csv).to include(rdv.starts_at&.strftime("%d/%m/%Y"))
      end
    end
  end
end
