describe Exporters::GenerateUsersParticipationsCsv, type: :service do
  subject do
    described_class.call(user_ids: users.ids, structure: structure, motif_category_id: motif_category.id, agent:)
  end

  let!(:now) { Time.zone.parse("22/06/2022") }
  let!(:timestamp) { now.to_i }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:motif) { create(:motif, motif_category: motif_category) }
  let!(:other_motif_category) { create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement") }
  let!(:other_motif) { create(:motif, motif_category: other_motif_category) }
  let!(:department) { create(:department, name: "Drôme", number: "26") }
  let!(:organisation) { create(:organisation, name: "Drome RSA", department: department) }
  let!(:organisation_prescripteur) { create(:organisation, name: "Ailleurs", department: department) }
  let!(:structure) { organisation }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:other_category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: other_motif_category)
  end
  let!(:nir) { generate_random_nir(sex: :female) }
  let!(:user1) do
    create(
      :user,
      first_name: "Jane",
      last_name: "Doe",
      title: "madame",
      affiliation_number: "12345",
      department_internal_id: "33333",
      nir: nir,
      france_travail_id: "DDAAZZ",
      email: "jane@doe.com",
      address: "20 avenue de Ségur paris",
      phone_number: "+33610101010",
      birth_date: "20/12/1980",
      rights_opening_date: "18/05/2022",
      created_at: "20/05/2022",
      role: "demandeur",
      organisations: [organisation],
      referents: [referent]
    )
  end
  let!(:address_geocoding) { create(:address_geocoding, user: user1, post_code: "75007", city: "Paris") }
  let(:user2) { create(:user, last_name: "Casubolo", organisations: [organisation]) }
  let(:user3) { create(:user, last_name: "Blanc", organisations: [organisation]) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:agent_prescripteur) do
    create(:agent, first_name: "Georges", last_name: "Prescipteur", email: "g@prescripteur.fr",
                   rdv_solidarites_agent_id: 123,
                   organisations: [organisation_prescripteur])
  end

  let!(:rdv) do
    create(:rdv, starts_at: Time.zone.parse("2022-05-25"),
                 created_by: "user",
                 organisation: organisation,
                 motif: motif,
                 participations: [participation_rdv])
  end
  let!(:participation_rdv) { create(:participation, user: user1, status: "seen", created_at: "2022-05-20") }

  let!(:rdv_other_motif_category) do
    create(:rdv, starts_at: Time.zone.parse("2022-05-30"),
                 created_by: "user",
                 organisation: organisation,
                 motif: other_motif,
                 participations: [participation_rdv_other_motif_category])
  end
  let!(:participation_rdv_other_motif_category) { create(:participation, user: user3, status: "seen") }

  let!(:rdv_prescrit) do
    create(:rdv, starts_at: Time.zone.parse("2022-05-25"),
                 created_by: "agent",
                 organisation: organisation,
                 motif: motif,
                 participations: [participation_rdv_prescrit])
  end
  let!(:participation_rdv_prescrit) do
    create(:participation,
      user: user2,
      status: "seen",
      rdv_solidarites_created_by_id: 123,
      created_by_type: "Agent",
      created_by_agent_prescripteur: true
    )
  end
  let!(:first_invitation) do
    create(:invitation, user: user1, format: "email", created_at: Time.zone.parse("2022-05-21"))
  end
  let!(:last_invitation) do
    create(:invitation, user: user1, format: "email", created_at: Time.zone.parse("2022-05-22"))
  end
  let!(:notification) do
    create(:notification, participation: participation_rdv, format: "email", created_at: Time.zone.parse("2022-06-22"))
  end
  let!(:follow_up) do
    create(
      :follow_up, invitations: [first_invitation, last_invitation],
                  motif_category: motif_category, participations: [participation_rdv],
                  user: user1, status: "rdv_needs_status_update"
    )
  end
  let!(:referent) do
    create(:agent, email: "monreferent@gouv.fr")
  end

  let!(:users) { User.where(id: [user1, user2, user3]) }

  describe "#call" do
    before { travel_to(now) }

    context "it exports users to csv" do
      let!(:csv) { subject.csv }

      it "is a success" do
        expect(subject.success?).to eq(true)
      end

      it "generates a filename" do
        expect(subject.filename).to eq("Export_rdvs_rsa_orientation_organisation_drome_rsa.csv")
      end

      it "generates headers" do
        expect(csv).to start_with("\uFEFF")
        expect(csv).to include("Statut du rdv")
        expect(csv).to include("Date du RDV")
        expect(csv).to include("Heure du RDV")
        expect(csv).to include("Motif du RDV")
        expect(csv).to include("Nature du RDV")
        expect(csv).to include("RDV pris en autonomie ?")
        expect(csv).to include("RDV pris le")
        expect(csv).to include("Référent(s)")
        expect(csv).to include("Organisation du rendez-vous")
        expect(csv).to include("Civilité")
        expect(csv).to include("Nom")
        expect(csv).to include("Prénom")
        expect(csv).to include("Numéro CAF")
        expect(csv).to include("ID interne au département")
        expect(csv).to include("ID France Travail")
        expect(csv).to include("ID interne au département")
        expect(csv).to include("Email")
        expect(csv).to include("Téléphone")
        expect(csv).to include("CP")
        expect(csv).to include("Ville")
        expect(csv).to include("Date de naissance")
        expect(csv).to include("Date de création")
        expect(csv).to include("Date d'entrée flux")
        expect(csv).to include("Rôle")
        expect(csv).to include("Rendez-vous prescrit ? (interne)")
        expect(csv).to include("Prénom du prescripteur (interne)")
        expect(csv).to include("Nom du prescripteur (interne)")
        expect(csv).to include("Mail du prescripteur (interne)")
        expect(csv).to include("Tags")
      end

      context "it exports all the concerned users" do
        it "generates one line for each participation" do
          expect(csv.scan(/(?=\n)/).count).to eq(3) # one line per participation + 1 line of headers
        end

        it "displays all participations" do
          expect(csv).to include("Doe")
          expect(csv).to include("Casubolo")
          expect(csv).not_to include("Blanc")
        end
      end

      context "it displays the right attributes" do
        let!(:users) { User.where(id: [user1]) }

        it "displays the users attributes" do
          expect(csv.scan(/(?=\n)/).count).to eq(2) # we check there is only one user for this test
          expect(csv).to include("madame")
          expect(csv).to include("Doe")
          expect(csv).to include("Jane")
          expect(csv).to include("12345") # affiliation_number
          expect(csv).to include("33333") # department_internal_id
          expect(csv).to include("DDAAZZ") # france_travail_id
          expect(csv).to include("20 avenue de Ségur paris")
          expect(csv).to include("75007")
          expect(csv).to include("Paris")
          expect(csv).to include("jane@doe.com")
          expect(csv).to include("+33610101010")
          expect(csv).to include("20/12/1980") # birth_date
          expect(csv).to include("20/05/2022") # created_at
          expect(csv).to include("18/05/2022") # rights_opening_date
          expect(csv).to include("demandeur") # role
        end

        it "displays the rdv infos" do
          expect(csv).to include("25/05/2022") # rdv date
          expect(csv).to include("0h00") # rdv time
          expect(csv).to include("RSA orientation sur site") # rdv motif
          expect(csv).to include("individuel") # rdv type
          expect(csv).to include("individuel;Oui") # rdv taken in autonomy ?
          expect(csv).to include("Oui;20/05/2022") # participation created_at
          expect(csv).to include("Rendez-vous honoré") # rdv status
        end

        it "displays the organisation infos" do
          expect(csv).to include("1")
          expect(csv).to include(participation_rdv.organisation.name)
        end

        it "displays the referent emails" do
          expect(csv).to include("monreferent@gouv.fr")
        end

        it "does not display the user nir" do
          expect(subject.csv).not_to include("Numéro de sécurité sociale")
          expect(csv).not_to include(user1.nir)
        end
      end

      context "it displays the right attributes for a prescribed participation row" do
        let!(:users) { User.where(id: [user2]) }

        it "displays the prescripteur attributes" do
          expect(csv.scan(/(?=\n)/).count).to eq(2) # we check there is only one user for this test
          expect(csv).to include("Casubolo")
          expect(csv).to include("oui")
          expect(csv).to include("Georges")
          expect(csv).to include("Prescipteur")
          expect(csv).to include("g@prescripteur.fr")
        end
      end

      context "when no motif category is passed" do
        subject { described_class.call(user_ids: users.ids, structure: structure, motif_category_id: nil, agent:) }

        it "is a success" do
          expect(subject.success?).to eq(true)
        end

        it "generates the right filename" do
          expect(subject.filename).to eq("Export_rdvs_organisation_drome_rsa.csv")
        end

        it "generates headers" do
          expect(csv).to start_with("\uFEFF")
          expect(csv).not_to include("Statut de la catégorie de motifs")
        end

        context "it exports all the concerned users" do
          it "generates one line for each participation" do
            expect(csv.scan(/(?=\n)/).count).to eq(4) # one line per participation + 1 line of headers
          end

          it "displays all participations" do
            expect(csv).to include("Doe")
            expect(csv).to include("Casubolo")
            expect(csv).to include("Blanc")
          end
        end
      end
    end

    context "when the user has multiple rdvs in multiple orgs" do
      let!(:other_organisation) { create(:organisation, department:, users: [user1]) }
      let!(:other_rdv) do
        create(:rdv, starts_at: Time.zone.parse("2022-01-22"),
                     created_by: "user",
                     motif: motif,
                     organisation: other_organisation)
      end
      let!(:other_participation) { create(:participation, rdv: other_rdv, user: user1) }

      context "when the agent belongs to the other org" do
        before do
          agent.organisations << other_organisation
        end

        it "displays the rdv" do
          expect(subject.csv).to include("22/01/2022")
        end

        context "when the org is in a different department" do
          let!(:other_organisation) do
            create(:organisation, department: other_department, name: "CD 01", users: [user1])
          end
          let!(:other_department) { create(:department, name: "Ain", number: "01") }

          it "displays the rdv" do
            expect(subject.csv).to include("22/01/2022")
          end

          it "precises the org is in another department" do
            expect(subject.csv).to include("CD 01 (Organisation d'un autre départment : 01 - Ain)")
          end
        end
      end

      context "when the agent does not belong to the other org" do
        it "does not display the rdv" do
          expect(subject.csv).not_to include("22/08/2022")
        end
      end
    end

    context "when the user has multiple tags in different organisations" do
      let!(:tag) { create(:tag, value: "cacahuète", users: [user1], organisations: [organisation]) }
      let!(:other_tag) { create(:tag, value: "pistache", users: [user1], organisations: [other_organisation]) }
      let!(:other_organisation) { create(:organisation, department:, users: [user1]) }

      context "at organisation level" do
        it "displays the user organisation tags" do
          expect(subject.csv).to include("cacahuète")
          expect(subject.csv).not_to include("pistache")
        end
      end

      context "at department level" do
        let!(:structure) { department }
        let!(:other_organisation_with_agent) { create(:organisation, department:, users: [user1]) }
        let!(:new_tag) do
          create(:tag, value: "chips", users: [user1], organisations: [other_organisation_with_agent])
        end

        before { agent.organisations << other_organisation_with_agent }

        it "displays the tags the agent has access to" do
          expect(subject.csv).to include("cacahuète")
          expect(subject.csv).not_to include("pistache")
          expect(subject.csv).to include("chips")
        end
      end
    end
  end
end
