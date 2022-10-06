describe Exports::GenerateApplicantsCsv, type: :service do
  subject { described_class.call(applicants: applicants, structure: structure, motif_category: motif_category) }

  let!(:timestamp) { Time.zone.now.to_i }
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
      created_at: "21/05/2022",
      role: "demandeur",
      organisations: [organisation],
      department: department,
      rdvs: [rdv]
    )
  end
  let(:applicant2) { create(:applicant, last_name: "Casubolo", organisations: [organisation]) }
  let(:applicant3) { create(:applicant, last_name: "Blanc", organisations: [organisation]) }

  let!(:rdv) do
    create(:rdv, status: "seen",
                 starts_at: Time.zone.parse("2022-05-25"),
                 created_by: "user")
  end
  let!(:first_invitation) do
    create(:invitation, applicant: applicant1, format: "email", sent_at: Time.zone.parse("2022-05-21"))
  end
  let!(:last_invitation) do
    create(:invitation, applicant: applicant1, format: "email", sent_at: Time.zone.parse("2022-05-22"))
  end
  let!(:rdv_context) do
    create(
      :rdv_context, rdvs: [rdv], invitations: [first_invitation, last_invitation],
                    applicant: applicant1, status: "rdv_needs_status_update"
    )
  end

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3]) }

  describe "#call" do
    context "it exports applicants to csv" do
      let!(:csv) { subject.csv }

      it "is a success" do
        expect(subject.success?).to eq(true)
      end

      it "generates a filename" do
        expect(subject.filename).to eq("Export_beneficiaires_rsa_orientation_organisation_drome_rsa.csv")
      end

      it "generates headers" do
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
        expect(csv).to include("Archivé le")
        expect(csv).to include("Motif d'archivage")
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

      context "it exports all the concerned applicants" do
        it "generates one line for each applicant required" do
          expect(csv.scan(/(?=\n)/).count).to eq(4) # one line per applicants + 1 line of headers
        end

        it "displays all the applicants" do
          expect(csv).to include("Doe")
          expect(csv).to include("Casubolo")
          expect(csv).to include("Blanc")
        end
      end

      context "it displays the right attributes" do
        let!(:applicants) { Applicant.where(id: [applicant1]) }

        it "displays the applicants attributes" do
          expect(csv.scan(/(?=\n)/).count).to eq(2) # we check there is only one applicant for this test
          expect(csv).to include("madame")
          expect(csv).to include("Doe")
          expect(csv).to include("Jane")
          expect(csv).to include("12345") # affiliation_number
          expect(csv).to include("33333") # department_internal_id
          expect(csv).to include("20 avenue de Ségur 75OO7 Paris")
          expect(csv).to include("jane@doe.com")
          expect(csv).to include("01 01 01 01 01")
          expect(csv).to include("20/12/1977") # birth_date
          expect(csv).to include("20/05/2022") # rights_opening_date
          expect(csv).to include("demandeur") # role
        end

        it "displays the invitations infos" do
          expect(csv).to include("21/05/2022") # first invitation date
          expect(csv).to include("22/05/2022") # last invitation date
          expect(csv).not_to include("(Délai dépassé)") # invitation delay
        end

        it "displays the rdvs infos" do
          expect(csv).to include("25/05/2022") # last rdv date
          expect(csv).to include("25/05/2022;oui") # last rdv taken in autonomy ?
          expect(csv).to include("Statut du RDV à préciser") # rdv_context status
          expect(csv).to include("Statut du RDV à préciser;oui") # first rdv in less than 30 days ?
          expect(csv).to include("25/05/2022;oui;Statut du RDV à préciser;oui;25/05/2022") # orientation date
        end

        it "displays the archiving infos" do
          expect(csv).to include("25/05/2022;\"\"") # archiving status
          expect(csv).to include("25/05/2022;\"\";;") # archiving reason
        end

        it "displays the department infos" do
          expect(csv).to include("26")
          expect(csv).to include("Drôme")
        end

        it "displays the organisation infos" do
          expect(csv).to include("1")
          expect(csv).to include("Drome RSA")
        end

        context "when the invitation deadline has passed" do
          let!(:rdv_context) do
            create(
              :rdv_context, rdvs: [], invitations: [first_invitation, last_invitation],
                            applicant: applicant1, status: "invitation_pending"
            )
          end

          it "displays 'délai dépassé'" do
            expect(subject.csv).to include("Invitation en attente de réponse (Délai dépassé)") # rdv_context status
          end
        end

        context "when the applicant is archived" do
          let!(:applicant1) do
            create(
              :applicant,
              archived_at: "20/06/2022",
              archiving_reason: "test",
              organisations: [organisation],
              department: department,
              rdvs: [rdv]
            )
          end
          let!(:csv) { subject.csv }

          it "displays the archiving infos" do
            expect(csv).to include("20/06/2022") # archiving status
            expect(csv).to include("20/06/2022;test") # archiving reason
          end

          it "does displays the archived status rather than the rdv_context status" do
            expect(csv).not_to include("Statut du RDV à préciser")
            expect(csv).to include("Archivé")
          end
        end
      end

      context "when no structure is passed" do
        let!(:structure) { nil }
        let!(:rdv_context) do
          create(
            :rdv_context, rdvs: [], invitations: [first_invitation, last_invitation],
                          applicant: applicant1, status: "invitation_pending"
          )
        end

        it "is a success" do
          expect(subject.success?).to eq(true)
        end

        it "generates a filename" do
          expect(subject.filename).to eq("Export_beneficiaires_#{timestamp}.csv")
        end

        it "does not displays 'délai dépassé' warnings" do
          csv = subject.csv
          expect(csv).to include("Invitation en attente de réponse") # rdv_context status
          expect(csv).not_to include("(Délai dépassé)")
        end
      end

      context "when no motif category is passed" do
        let!(:motif_category) { nil }

        it "is a success" do
          expect(subject.success?).to eq(true)
        end

        it "generates the right filename" do
          expect(subject.filename).to eq("Export_beneficiaires_organisation_drome_rsa.csv")
        end

        it "does not display the statuses" do
          expect(subject.csv).not_to include("Statut du RDV à préciser")
        end
      end
    end
  end
end
