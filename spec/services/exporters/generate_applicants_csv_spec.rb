describe Exporters::GenerateApplicantsCsv, type: :service do
  subject { described_class.call(applicants: applicants, structure: structure, motif_category: motif_category) }

  let!(:motif_category) { "rsa_orientation" }
  let!(:department) { create(:department, name: "Drôme", number: "26") }
  let!(:organisation) do
    create(:organisation, configurations: [configuration], name: "Drome RSA", department: department)
  end
  let!(:configuration) { create(:configuration, motif_category: motif_category) }
  let!(:structure) { organisation }
  let!(:applicant1) do
    create(
      :applicant,
      first_name: "Jane",
      last_name: "Doe",
      title: "madame",
      affiliation_number: "12345",
      department_internal_id: "33333",
      email: "jane@doe.com",
      address: "20 avenue de Ségur 75OO7 Paris",
      phone_number: "01 01 01 01 01",
      birth_date: "20/12/1977",
      rights_opening_date: "20/05/2022",
      role: "demandeur",
      archived_at: "20/06/2022",
      archiving_reason: "traité",
      organisations: [organisation],
      department: department
    )
  end
  let(:applicant2) { create(:applicant, last_name: "Casubolo", organisations: [organisation]) }
  let(:applicant3) { create(:applicant, last_name: "Blanc", organisations: [organisation]) }

  let!(:rdv) { create(:rdv, status: "unknown", starts_at: Time.zone.parse("2022-05-25"), created_by: "user") }
  let!(:invitation) do
    create(:invitation, applicant: applicant1, format: "email", sent_at: Time.zone.parse("2022-05-21"))
  end
  let!(:rdv_context) do
    create(
      :rdv_context, rdvs: [rdv], invitations: [invitation], applicant: applicant1, status: "rdv_needs_status_update"
    )
  end

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3]) }

  describe "#call" do
    context "it exports applicants to csv" do
      it "is a success" do
        expect(subject.success?).to eq(true)
      end

      it "generates a filename" do
        expect(subject.filename).to eq("Liste_beneficiaires_rsa_orientation_organisation_drome_rsa.csv")
      end

      it "generates headers" do
        csv = subject.csv
        expect(csv).to start_with("\uFEFF")
        expect(csv).to include("Civilité")
        expect(csv).to include("Nom")
        expect(csv).to include("Prénom")
        expect(csv).to include("Numéro d'allocataire")
        expect(csv).to include("ID interne au département")
        expect(csv).to include("Email")
        expect(csv).to include("Téléphone")
        expect(csv).to include("Date de naissance")
        expect(csv).to include("Date d'entrée flux")
        expect(csv).to include("Rôle")
        expect(csv).to include("Motif d'archivage")
        expect(csv).to include("Archivé le")
        expect(csv).to include("Statut")
        expect(csv).to include("Première invitation envoyée le")
        expect(csv).to include("Dernière invitation envoyée le")
        expect(csv).to include("Date du dernier RDV")
        expect(csv).to include("Dernier RDV pris en autonomie ?")
        expect(csv).to include("RDV honoré en - de 30 jours ?")
        expect(csv).to include("Date d'orientation")
        expect(csv).to include("Numéro du département")
        expect(csv).to include("Nom du département")
        expect(csv).to include("Nombre d'organisations")
        expect(csv).to include("Nom des organisations")
      end

      it "generates one line for each applicant required" do
        expect(subject.csv.scan(/(?=\n)/).count).to eq(applicants.count + 1)
      end

      it "displays all the applicants" do
        csv = subject.csv
        expect(csv).to include("Doe")
        expect(csv).to include("Casubolo")
        expect(csv).to include("Blanc")
      end

      it "display the applicants attributes" do
        csv = subject.csv
        expect(csv).to include("madame")
        expect(csv).to include("Doe")
        expect(csv).to include("Jane")
        expect(csv).to include("12345")
        expect(csv).to include("33333")
        expect(csv).to include("jane@doe.com")
        expect(csv).to include("01 01 01 01 01")
        expect(csv).to include("20/12/1977")
        expect(csv).to include("20/05/2022")
        expect(csv).to include("demandeur")

        # rdv_context
        expect(csv).to include("Statut du RDV à préciser")

        # archiving
        expect(csv).to include("traité")
        expect(csv).to include("20/06/2022")
        # invitation
        expect(csv).to include("21/05/2022")
        # rdv
        expect(csv).to include("25/05/2022")
        expect(csv).to include("oui")
        expect(csv).to include("non")

        expect(csv).to include("26")
        expect(csv).to include("Drôme")

        expect(csv).to include("1")
        expect(csv).to include("Drome RSA")
      end
    end
  end
end
