describe ArchivesController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:configuration) do
    create(:configuration, motif_category: category_orientation, organisation: organisation)
  end
  let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }

  describe "#index" do
    let!(:applicant) do
      create(
        :applicant,
        organisations: [organisation], last_name: "Chabat", rdv_contexts: [rdv_context1]
      )
    end
    let!(:rdv_context1) { build(:rdv_context, motif_category: category_orientation, status: "rdv_seen") }

    let!(:archived_applicant) do
      create(
        :applicant,
        created_at: Time.zone.parse("2023-03-10 12:30"),
        organisations: [organisation], last_name: "Barthelemy", rdv_contexts: [rdv_context2]
      )
    end
    let!(:archive) do
      create(:archive, applicant: archived_applicant, department: department,
                       created_at: Time.zone.parse("2023-03-30 12:30"))
    end
    let!(:rdv_context2) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:archived_applicant2) do
      create(
        :applicant,
        created_at: Time.zone.parse("2023-04-10 12:30"),
        organisations: [organisation], last_name: "Darmon", rdv_contexts: [rdv_context3]
      )
    end
    let!(:archive2) do
      create(:archive, applicant: archived_applicant2, department: department,
                       created_at: Time.zone.parse("2023-04-30 12:30"))
    end
    let!(:rdv_context3) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:index_params) { { organisation_id: organisation.id } }

    render_views

    before do
      sign_in(agent)
    end

    it "returns a list of the archived applicants" do
      get :index, params: index_params

      expect(response).to be_successful
      expect(response.body).not_to match(/Chabat/)
      expect(response.body).to match(/Barthelemy/)
      expect(response.body).to match(/Darmon/)
    end

    it "does not display the configure organisation option" do
      get :index, params: index_params

      expect(response.body).not_to match(/Configurer l'organisation/)
    end

    it "displays the applicants creation date and the corresponding filter" do
      get :index, params: index_params

      expect(response.body).to match(/Date de création/)
      expect(response.body).to match(/Filtrer par date de création/)
    end

    it "displays the archiving date and the corresponding filter" do
      get :index, params: index_params

      expect(response.body).to match(/Archivé le/)
      expect(response.body).to match(/Filtrer par date d'archivage/)
    end

    context "when the agent is admin" do
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

      before do
        sign_in(agent)
      end

      it "displays the configure organisation option" do
        get :index, params: index_params

        expect(response.body).to match(/Configurer l'organisation/)
      end
    end

    context "when a search query is specified" do
      let!(:index_params) do
        { organisation_id: organisation.id, search_query: "barthelemy" }
      end

      it "searches the applicants" do
        get :index, params: index_params
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Barthelemy/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when creation dates are passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, applicants_creation_date_after: "01-03-2023",
          applicants_creation_date_before: "30-03-2023" }
      end

      it "filters by creation dates" do
        get :index, params: index_params
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Barthelemy/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when archiving dates are passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, archiving_date_after: "01-03-2023",
          archiving_date_before: "30-03-2023" }
      end

      it "filters by creation dates" do
        get :index, params: index_params
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Barthelemy/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when filter_by_current_agent is passed" do
      let!(:index_params) do
        {
          organisation_id: organisation.id,
          filter_by_current_agent: "true"
        }
      end

      before { archived_applicant.referents = [agent] }

      it "filters on the applicants assigned to the agent" do
        get :index, params: index_params
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Barthelemy/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when department level" do
      let!(:index_params) { { department_id: department.id } }

      it "renders the index page" do
        get :index, params: index_params

        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Barthelemy/)
        expect(response.body).to match(/Darmon/)
      end

      it "does not display the configure organisation option" do
        get :index, params: index_params

        expect(response.body).not_to match(/Configurer une organisation/)
      end

      context "when the agent is admin" do
        let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

        before do
          sign_in(agent)
        end

        it "displays the configure organisation option" do
          get :index, params: index_params

          expect(response.body).to match(/Configurer une organisation/)
        end
      end
    end

    context "when csv request" do
      before do
        allow(Exporters::GenerateApplicantsCsv).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(Exporters::GenerateApplicantsCsv).to receive(:call)
        get :index, params: index_params.merge(format: :csv)
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
        end

        it "does not call the service" do
          expect do
            get :index, params: index_params.merge(format: :csv)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the csv creation succeeds" do
        before do
          allow(Exporters::GenerateApplicantsCsv).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "is a success" do
          get :index, params: index_params.merge(format: :csv)
          expect(response).to be_successful
        end
      end
    end
  end
end
