RSpec.describe CsvExportMailer do
  let!(:department) { create(:department) }
  let!(:organisation1) { create(:organisation, department: department) }
  let!(:organisation2) { create(:organisation, department: department) }
  let!(:agent) { create(:agent, organisations: [organisation1, organisation2]) }
  let!(:export) do
    create(:csv_export, structure_type: "Organisation", structure_id: organisation1.id, kind: "users_csv",
                        agent_id: agent.id, request_params: request_params)
  end
  let!(:request_params) { { organisation_id: organisation1.id } }

  describe "#notify_csv_export" do
    subject do
      described_class.notify_csv_export(agent.email, export)
    end

    it "renders the headers" do
      expect(subject.to).to eq([agent.email])
      expect(subject.subject).to eq("[rdv-insertion] Export CSV")
    end

    it "renders the body" do
      body_string = unescape_html(subject.body.encoded)
      expect(body_string).to match("Voici l'export CSV que vous avez demandé sur notre plateforme.")
      expect(body_string).to match(
        "Ce lien de téléchargement n'est valable que pendant 48 heures à partir de l'envoi de ce mail."
      )
      expect(body_string).to match("L'export a été réalisé à partir des critères suivants")
      expect(body_string).to match("<strong>Type d'export</strong>&nbsp;:")
      expect(body_string).to match("export des usagers")
      expect(body_string).to match("<strong>Périmètre</strong>&nbsp;:")
      expect(body_string).to match(organisation1.name)
      expect(body_string).not_to match(organisation2.name)
    end

    context "when the export is for a department" do
      let!(:export) do
        create(:csv_export, structure_type: "Department", structure_id: department.id, kind: "users_csv",
                            agent_id: agent.id, request_params: request_params)
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match(organisation1.name)
        expect(body_string).to match(organisation2.name)
      end
    end

    context "when the export is for participations" do
      before do
        export.update(kind: "users_participations_csv")
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("export des rendez-vous des usagers")
      end
    end

    context "when different filters are set" do
      let!(:motif_category) { create(:motif_category) }
      let!(:tag) { create(:tag) }
      let!(:request_params) do
        {
          action_required: "true", first_invitation_date_before: "15-04-2024",
          last_invitation_date_after: "01-01-2024", last_invitation_date_before: "02-04-2024",
          motif_category_id: motif_category.id.to_s,
          referent_id: agent.id.to_s, search_query: "Bacri", follow_up_statuses: ["invitation_pending"],
          tag_ids: [tag.id.to_s], organisation_id: organisation1.id.to_s
        }
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Catégorie")
        expect(body_string).to match(motif_category.name)
        expect(body_string).to match("Statut")
        expect(body_string).to match("Invitation en attente de réponse")
        expect(body_string).to match("Référent")
        expect(body_string).to match(agent.to_s)
        expect(body_string).to match("Date de première invitation")
        expect(body_string).to match("avant le 15/04/2024")
        expect(body_string).to match("Date de dernière invitation")
        expect(body_string).to match("entre 01/01/2024 et le 02/04/2024")
        expect(body_string).to match("Usagers avec intervention nécessaire")
        expect(body_string).to match("Champ de recherche libre")
        expect(body_string).to match("Bacri")
        expect(body_string).to match("Tags")
        expect(body_string).to match(tag.value)
      end
    end
  end
end
