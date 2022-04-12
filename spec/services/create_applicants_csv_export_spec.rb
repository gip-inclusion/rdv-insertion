describe CreateApplicantsCsvExport, type: :service do
  subject { described_class.call(applicants: applicants, structure: structure, context: context) }

  let!(:context) { "rsa_orientation" }
  let!(:organisation) { create(:organisation) }
  let!(:structure) { :organisation }
  let(:applicant1) { create(:applicant, last_name: "Dhobb", organisations: [organisation]) }
  let(:applicant2) { create(:applicant, last_name: "Casubolo", organisations: [organisation]) }
  let(:applicant3) { create(:applicant, last_name: "Blanc", organisations: [organisation]) }
  let(:applicant4) { create(:applicant, last_name: "Prébot", organisations: [organisation]) }
  let!(:applicants) { [applicant1, applicant2, applicant3] }

  describe "#call" do
    context "it exports applicants to csv" do
      it "is a success" do
        expect(subject.success?).to eq(true)
      end

      context "it generates a filename" do
        context "structure is present" do
          it "generates a filename with structure" do
            expect(subject.filename).to eq("#{structure.class.name}_#{structure.name \
              .parameterize(separator: '_')}_applicants_extraction.csv")
          end
        end

        context "structure is nil" do
          let!(:structure) { nil }

          it "generates a generic filename" do
            expect(subject.filename).to eq("applicants_extraction.csv")
          end
        end
      end

      it "generates headers" do
        expect(subject.csv).to start_with("Civilité;Nom;Prénom;Numéro d'allocataire;ID interne au département;Email;")
      end

      it "generates one line for each applicant required" do
        expect(subject.csv.scan(/(?=\n)/).count).to eq(applicants.count + 1)
      end

      it "includes the required applicants" do
        expect(subject.csv).to include("Dhobb")
        expect(subject.csv).to include("Casubolo")
        expect(subject.csv).to include("Blanc")
        expect(subject.csv).not_to include("Prébot")
      end
    end
  end
end
