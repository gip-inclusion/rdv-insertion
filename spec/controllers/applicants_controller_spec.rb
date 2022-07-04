describe ApplicantsController, type: :controller do
  let!(:department) { create(:department) }
  let!(:configuration) do
    create(
      :configuration,
      motif_category: "rsa_orientation",
      number_of_days_before_action_required: number_of_days_before_action_required
    )
  end
  let!(:number_of_days_before_action_required) { 3 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                          department_id: department.id, configurations: [configuration])
  end
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:rdv_solidarites_organisation_id) { 52 }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let(:applicant) { create(:applicant, organisations: [organisation], department: department) }

  describe "#new" do
    let!(:new_params) { { organisation_id: organisation.id } }

    render_views

    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    it "renders the new applicant page" do
      get :new, params: new_params

      expect(response).to be_successful
      expect(response.body).to match(/Créer allocataire/)
    end
  end

  describe "#create" do
    render_views
    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
      allow(FindOrInitializeApplicant).to receive(:call)
        .and_return(OpenStruct.new(success?: true, applicant: applicant))
      allow(Applicant).to receive(:new)
        .and_return(applicant)
      allow(applicant).to receive(:assign_attributes)
      allow(SaveApplicant).to receive(:call)
        .and_return(OpenStruct.new)
    end

    let(:applicant_params) do
      {
        applicant: {
          uid: "123xz", first_name: "john", last_name: "doe", email: "johndoe@example.com",
          affiliation_number: "1234", role: "conjoint"
        },
        organisation_id: organisation.id
      }
    end

    it "calls the FindOrInitializeApplicant service" do
      expect(FindOrInitializeApplicant).to receive(:call)
      post :create, params: applicant_params
    end

    it "assigns the attributes" do
      expect(applicant).to receive(:assign_attributes)
      post :create, params: applicant_params
    end

    it "calls the SaveApplicant service" do
      expect(SaveApplicant).to receive(:call)
      post :create, params: applicant_params
    end

    context "when html request" do
      let(:applicant_params) do
        {
          applicant: {
            first_name: "john", last_name: "doe", email: "johndoe@example.com",
            affiliation_number: "1234", role: "demandeur", title: "monsieur"
          },
          organisation_id: organisation.id,
          format: "html"
        }
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }

        it "raises an error" do
          expect do
            post :create, params: applicant_params.merge(organisation_id: another_organisation.id)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the creation succeeds" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "is a success" do
          post :create, params: applicant_params
          expect(response).to redirect_to(organisation_applicant_path(organisation, applicant))
        end
      end

      context "when the creation fails" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ['some error']))
        end

        it "renders the new page" do
          post :create, params: applicant_params
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(response.body).to match(/Créer allocataire/)
        end
      end
    end

    context "when json request" do
      before { request.accept = "application/json" }

      let(:applicant_params) do
        {
          applicant: {
            uid: "123xz", first_name: "john", last_name: "doe", email: "johndoe@example.com",
            affiliation_number: "1234", role: "conjoint"
          },
          organisation_id: organisation.id
        }
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }

        it "raises an error" do
          expect do
            post :create, params: applicant_params.merge(organisation_id: another_organisation.id)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the creation succeeds" do
        let!(:applicant) { create(:applicant, organisations: [organisation], department: department) }

        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: true, applicant: applicant))
        end

        it "is a success" do
          post :create, params: applicant_params
          expect(response).to be_successful
          expect(JSON.parse(response.body)["success"]).to eq(true)
        end

        it "renders the applicant" do
          post :create, params: applicant_params
          expect(response).to be_successful
          expect(JSON.parse(response.body)["applicant"]["id"]).to eq(applicant.id)
        end
      end

      context "when the creation fails" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ['some error']))
        end

        it "is not a success" do
          post :create, params: applicant_params
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["success"]).to eq(false)
        end

        it "renders the errors" do
          post :create, params: applicant_params
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["errors"]).to eq(['some error'])
        end
      end
    end
  end

  describe "#search" do
    let!(:search_params) { { applicants: { department_internal_ids: %w[331 552], uids: ["23"] }, format: "json" } }
    let!(:applicant) { create(:applicant, organisations: [organisation], email: "borisjohnson@gov.uk") }

    before do
      applicant.update_columns(uid: "23") # used to skip callbacks and computation of uid
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    context "policy scope" do
      let!(:another_organisation) { create(:organisation) }
      let!(:agent) { create(:agent, organisations: [another_organisation]) }
      let!(:another_applicant) { create(:applicant, organisations: [another_organisation]) }
      let!(:search_params) do
        { applicants: { department_internal_ids: %w[331 552], uids: %w[23 0332] }, format: "json" }
      end

      before { another_applicant.update_columns(uid: "0332") }

      it "returns the policy scoped applicants" do
        post :search, params: search_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["applicants"].pluck("id")).to contain_exactly(another_applicant.id)
      end
    end

    it "is a success" do
      post :search, params: search_params
      expect(response).to be_successful
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "renders the applicants" do
      post :search, params: search_params
      expect(response).to be_successful
      expect(JSON.parse(response.body)["applicants"].pluck("id")).to contain_exactly(applicant.id)
    end
  end

  describe "#show" do
    let!(:applicant) do
      create(
        :applicant, first_name: "Andreas", last_name: "Kopke", organisations: [organisation], department: department
      )
    end
    let!(:show_params) { { id: applicant.id, organisation_id: organisation.id } }

    render_views

    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    context "when organisation_level" do
      it "renders the applicant page" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Voir sur RDV-Solidarités/)
        expect(response.body).to match(/Andreas/)
        expect(response.body).to match(/Kopke/)
      end
    end

    context "when department_level" do
      let!(:show_params) { { id: applicant.id, department_id: department.id } }

      it "renders the applicant page" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Voir sur RDV-Solidarités/)
        expect(response.body).to match(/Andreas/)
        expect(response.body).to match(/Kopke/)
      end
    end

    context "when applicant is archived" do
      let!(:applicant) { create(:applicant, is_archived: true, organisations: [organisation]) }
      let!(:show_params) { { id: applicant.id, organisation_id: organisation.id } }

      it "the applicant is displayed as archived" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Dossier archivé/)
        expect(response.body).to match(/Motif d&#39;archivage/)
      end
    end

    context "when it belongs to all department organisations" do
      it "does not show the add to organisation button" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).not_to match(/Ajouter à une organisation/)
      end
    end

    context "when it does not belong to all department organisations" do
      let!(:other_org) { create(:organisation, department: department) }

      it "shows the add to organisation button" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Ajouter à une organisation/)
      end
    end

    context "it shows the different contexts" do
      let!(:configuration) do
        create(:configuration, motif_category: "rsa_orientation", invitation_formats: %w[sms email])
      end
      let!(:configuration2) do
        create(:configuration, motif_category: "rsa_accompagnement", invitation_formats: %w[sms email postal])
      end

      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                              department_id: department.id, configurations: [configuration, configuration2])
      end

      let!(:rdv_context) do
        create(:rdv_context, status: "rdv_seen", applicant: applicant, motif_category: "rsa_orientation")
      end
      let!(:invitation_orientation) do
        create(:invitation, sent_at: "2021-10-20", format: "sms", rdv_context: rdv_context)
      end

      let!(:rdv_orientation1) do
        create(
          :rdv,
          status: "noshow", created_at: "2021-10-21", starts_at: "2021-10-22",
          applicants: [applicant], rdv_contexts: [rdv_context], organisation: organisation
        )
      end

      let!(:rdv_orientation2) do
        create(
          :rdv,
          status: "seen", created_at: "2021-10-23", starts_at: "2021-10-24",
          applicants: [applicant], rdv_contexts: [rdv_context], organisation: organisation
        )
      end

      let!(:rdv_context2) do
        create(:rdv_context, status: "invitation_pending", applicant: applicant, motif_category: "rsa_accompagnement")
      end

      let!(:invitation_accompagnement) do
        create(:invitation, sent_at: "2021-11-20", format: "sms", rdv_context: rdv_context2)
      end

      it "shows all the contexts" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/RSA orientation/)
        expect(response.body).to match(/RDV honoré/)
        expect(response.body).to match(/RDV pris le/)
        expect(response.body).to match(/Date du RDV/)
        expect(response.body).to match(/Statut RDV/)
        expect(response.body).to include("21/10/2021")
        expect(response.body).to include("22/10/2021")
        expect(response.body).to include("23/10/2021")
        expect(response.body).to include("24/10/2021")
        expect(response.body).to match(/Absence non excusée/)
        expect(response.body).to match(/Rendez-vous honoré/)
        expect(response.body).to match(/Statut RDV/)
        expect(response.body).to match(/Statut RDV/)
        expect(response.body).to match(/RSA accompagnement/)
        expect(response.body).to match(/Invitation en attente de réponse/)
      end
    end
  end

  describe "#index" do
    let!(:applicant) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Chabat", rdv_contexts: [rdv_context1]
      )
    end
    let!(:rdv_context1) { build(:rdv_context, motif_category: "rsa_orientation", status: "rdv_seen") }

    let!(:applicant2) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Baer", rdv_contexts: [rdv_context2]
      )
    end
    let!(:rdv_context2) { build(:rdv_context, motif_category: "rsa_orientation", status: "invitation_pending") }

    let!(:applicant3) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Darmon", rdv_contexts: [rdv_context3]
      )
    end
    let!(:rdv_context3) { build(:rdv_context, motif_category: "rsa_orientation", status: "invitation_pending") }

    let!(:index_params) { { organisation_id: organisation.id, motif_category: "rsa_orientation" } }

    render_views

    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    it "returns a list of applicants" do
      get :index, params: index_params

      expect(response).to be_successful
      expect(response.body).to match(/Chabat/)
      expect(response.body).to match(/Baer/)
    end

    context "when a context is specified" do
      let!(:rdv_context2) { build(:rdv_context, motif_category: "rsa_accompagnement", status: "invitation_pending") }
      let!(:configuration) { create(:configuration, motif_category: "rsa_accompagnement") }

      it "returns the list of applicants in the current context" do
        get :index, params: index_params.merge(motif_category: "rsa_accompagnement")

        expect(response).to be_successful
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Baer/)
      end
    end

    context "when a search query is specified" do
      let!(:index_params) do
        { organisation_id: organisation.id, search_query: "chabat", motif_category: "rsa_orientation" }
      end

      it "searches the applicants" do
        get :index, params: index_params
        expect(response.body).to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
      end
    end

    context "when a status is passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, status: "invitation_pending", motif_category: "rsa_orientation" }
      end

      it "filters by status" do
        get :index, params: index_params
        expect(response.body).to match(/Baer/)
        expect(response.body).not_to match(/Chabat/)
      end
    end

    context "when dates are passed" do
      let!(:invitation1) do
        create(:invitation, sent_at: DateTime.new(2022, 6, 1, 10, 0), rdv_context: rdv_context1, applicant: applicant)
      end
      let!(:invitation2) do
        create(:invitation, sent_at: DateTime.new(2022, 6, 8, 10, 0), rdv_context: rdv_context2, applicant: applicant2)
      end
      let!(:invitation3) do
        create(:invitation, sent_at: DateTime.new(2022, 6, 15, 10, 0), rdv_context: rdv_context3, applicant: applicant3)
      end

      context "for first invitations" do
        let!(:index_params) do
          { organisation_id: organisation.id, motif_category: "rsa_orientation",
            first_invitation_date_after: "05-06-2022", first_invitation_date_before: "10-06-2022" }
        end

        it "filters by first invitations dates" do
          get :index, params: index_params
          expect(response.body).to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
          expect(response.body).not_to match(/Darmon/)
        end
      end

      context "for last invitations" do
        let!(:invitation4) do
          create(:invitation, sent_at: DateTime.new(2022, 6, 16, 10, 0),
                              rdv_context: rdv_context1, applicant: applicant)
        end
        let!(:invitation5) do
          create(:invitation, sent_at: DateTime.new(2022, 6, 19, 10, 0),
                              rdv_context: rdv_context2, applicant: applicant2)
        end
        let!(:invitation6) do
          create(:invitation, sent_at: DateTime.new(2022, 6, 17, 10, 0),
                              rdv_context: rdv_context3, applicant: applicant3)
        end

        let!(:index_params) do
          { organisation_id: organisation.id, motif_category: "rsa_orientation",
            last_invitation_date_after: "17-06-2022", last_invitation_date_before: "17-06-2022" }
        end

        it "filters by last invitations dates" do
          get :index, params: index_params
          expect(response.body).not_to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
          expect(response.body).to match(/Darmon/)
        end
      end
    end

    context "when action_required is passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, action_required: "true", motif_category: "rsa_orientation" }
      end
      let!(:number_of_days_before_action_required) { 4 }

      context "when the invitation has been sent before the number of days defined in the configuration ago" do
        let!(:invitation) { create(:invitation, applicant: applicant2, rdv_context: rdv_context2, sent_at: 5.days.ago) }

        it "filters by action required" do
          get :index, params: index_params
          expect(response.body).to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
        end
      end

      context "when the invitation has been sent after the number of days defined in the configuration 3 days ago" do
        let!(:invitation) { create(:invitation, applicant: applicant2, rdv_context: rdv_context2, sent_at: 3.days.ago) }

        it "filters by action required" do
          get :index, params: index_params
          expect(response.body).not_to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
        end
      end
    end

    context "when department level" do
      let!(:index_params) { { department_id: department.id, motif_category: "rsa_orientation" } }

      it "renders the index page" do
        get :index, params: index_params

        expect(response.body).to match(/Chabat/)
        expect(response.body).to match(/Baer/)
      end
    end

    context "when no context is specified" do
      let!(:applicant) do
        create(:applicant, organisations: [organisation], last_name: "Chabat", rdv_contexts: [])
      end

      let!(:rdv_context2) { build(:rdv_context, motif_category: "rsa_accompagnement", status: "invitation_pending") }

      it "lists the applicants with no rdv contexts in the contexts of the org configs" do
        get :index, params: index_params.merge(motif_category: nil)

        expect(response.body).to match(/Chabat/)
        expect(response.body).to match(/Baer/)
      end
    end

    context "when csv request" do
      before do
        allow(GenerateApplicantsCsv).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(GenerateApplicantsCsv).to receive(:call)
        get :index, params: index_params.merge(format: :csv)
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
          setup_rdv_solidarites_session(rdv_solidarites_session)
        end

        it "does not call the service" do
          expect do
            get :index, params: index_params.merge(format: :csv)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the csv creation succeeds" do
        before do
          allow(GenerateApplicantsCsv).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "is a success" do
          get :index, params: index_params.merge(format: :csv)
          expect(response).to be_successful
        end
      end
    end
  end

  describe "#edit" do
    let!(:applicant) { create(:applicant, organisations: [organisation]) }

    render_views

    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    context "when organisation_level" do
      let!(:edit_params) { { id: applicant.id, organisation_id: organisation.id } }

      it "renders the edit applicant page" do
        get :edit, params: edit_params

        expect(response).to be_successful
        expect(response.body).to match(/Modifier allocataire/)
      end
    end

    context "when department_level" do
      let!(:edit_params) { { id: applicant.id, department_id: department.id } }

      it "renders the edit applicant page" do
        get :edit, params: edit_params

        expect(response).to be_successful
        expect(response.body).to match(/Modifier allocataire/)
      end
    end
  end

  describe "#update" do
    let!(:applicant) { create(:applicant, organisations: [organisation]) }
    let!(:update_params) { { id: applicant.id, organisation_id: organisation.id, applicant: { is_archived: true } } }

    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    context "when json request" do
      let(:update_params) do
        {
          applicant: {
            is_archived: true
          },
          id: applicant.id,
          organisation_id: organisation.id,
          format: "json"
        }
      end

      before do
        allow(SaveApplicant).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(SaveApplicant).to receive(:call)
        post :update, params: update_params
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
          setup_rdv_solidarites_session(rdv_solidarites_session)
        end

        it "does not call the service" do
          expect do
            post :update, params: update_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the update succeeds" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: true, applicant: applicant))
        end

        it "is a success" do
          post :update, params: update_params
          expect(response).to be_successful
          expect(JSON.parse(response.body)["success"]).to eq(true)
        end
      end

      context "when the creation fails" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ['some error']))
        end

        it "is not a success" do
          post :update, params: update_params
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["success"]).to eq(false)
        end

        it "renders the errors" do
          post :update, params: update_params
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["errors"]).to eq(['some error'])
        end
      end
    end

    context "when html request" do
      let!(:update_params) do
        { id: applicant.id, organisation_id: organisation.id,
          applicant: { first_name: "Alain", last_name: "Deloin", phone_number: "0123456789" } }
      end

      before do
        sign_in(agent)
        setup_rdv_solidarites_session(rdv_solidarites_session)
        allow(SaveApplicant).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(SaveApplicant).to receive(:call)
          .with(
            applicant: applicant,
            organisation: organisation,
            rdv_solidarites_session: rdv_solidarites_session
          )
        patch :update, params: update_params
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
          setup_rdv_solidarites_session(rdv_solidarites_session)
        end

        it "does not call the service" do
          expect do
            patch :update, params: update_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the update succeeds" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: true, applicant: applicant))
        end

        context "when organisation level" do
          it "redirects to the show page" do
            patch :update, params: update_params
            expect(response).to redirect_to(organisation_applicant_path(organisation, applicant))
          end
        end

        context "when department level" do
          let!(:update_params) do
            { id: applicant.id, department_id: department.id,
              applicant: { first_name: "Alain", last_name: "Deloin", phone_number: "0123456789" } }
          end

          it "redirects to the show page" do
            patch :update, params: update_params
            expect(response).to redirect_to(department_applicant_path(department, applicant))
          end
        end
      end

      context "when the creation fails" do
        before do
          allow(SaveApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ['some error']))
        end

        it "renders the edit page" do
          patch :update, params: update_params
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
        end
      end
    end
  end
end
