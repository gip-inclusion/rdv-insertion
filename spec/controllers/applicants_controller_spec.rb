describe ApplicantsController do
  let!(:department) { create(:department) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:category_accompagnement) do
    create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement")
  end
  let!(:configuration) do
    create(
      :configuration,
      motif_category: category_orientation,
      number_of_days_before_action_required: number_of_days_before_action_required
    )
  end
  let!(:number_of_days_before_action_required) { 3 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                          department_id: department.id, configurations: [configuration])
  end
  let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }
  let!(:rdv_solidarites_organisation_id) { 888 }
  let(:applicant) { create(:applicant, organisations: [organisation], department: department) }

  describe "#new" do
    let!(:new_params) { { organisation_id: organisation.id } }

    render_views

    before do
      sign_in(agent)
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
      allow(Applicants::FindOrInitialize).to receive(:call)
        .and_return(OpenStruct.new(success?: true, applicant: applicant))
      allow(Applicant).to receive(:new)
        .and_return(applicant)
      allow(applicant).to receive(:assign_attributes)
      allow(Applicants::Save).to receive(:call)
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

    it "calls the Applicants::FindOrInitialize service" do
      expect(Applicants::FindOrInitialize).to receive(:call)
      post :create, params: applicant_params
    end

    it "assigns the attributes" do
      expect(applicant).to receive(:assign_attributes)
      post :create, params: applicant_params
    end

    it "calls the Applicants::Save service" do
      expect(Applicants::Save).to receive(:call)
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
          allow(Applicants::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "is a success" do
          post :create, params: applicant_params
          expect(response).to redirect_to(organisation_applicant_path(organisation, applicant))
        end
      end

      context "when the creation fails" do
        before do
          allow(Applicants::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "renders the new page" do
          post :create, params: applicant_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
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
          allow(Applicants::Save).to receive(:call)
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
          allow(Applicants::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "is not a success" do
          post :create, params: applicant_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["success"]).to eq(false)
        end

        it "renders the errors" do
          post :create, params: applicant_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to eq(["some error"])
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
      let!(:applicant) { create(:applicant, archived_at: 2.days.ago, organisations: [organisation]) }
      let!(:show_params) { { id: applicant.id, organisation_id: organisation.id } }

      it "the applicant is displayed as archived" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Dossier archivé/)
        expect(response.body).to match(/Motif d&#39;archivage/)
      end
    end

    context "it shows the different contexts" do
      let!(:configuration) do
        create(:configuration, motif_category: category_orientation, invitation_formats: %w[sms email])
      end
      let!(:configuration2) do
        create(:configuration, motif_category: category_accompagnement, invitation_formats: %w[sms email postal])
      end

      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                              department_id: department.id, configurations: [configuration, configuration2])
      end

      let!(:rdv_context) do
        create(:rdv_context, status: "rdv_seen", applicant: applicant, motif_category: category_orientation)
      end
      let!(:invitation_orientation) do
        create(:invitation, sent_at: "2021-10-20", format: "sms", rdv_context: rdv_context)
      end

      let!(:motif) { create(:motif, name: "RSA Orientation sur site") }

      let!(:rdv_orientation1) do
        create(
          :rdv,
          starts_at: "2021-10-22", motif: motif,
          organisation: organisation
        )
      end
      let!(:participation) do
        create(
          :participation,
          rdv: rdv_orientation1, rdv_context: rdv_context, applicant: applicant, status: "noshow",
          created_at: "2021-10-21"
        )
      end

      let!(:rdv_orientation2) do
        create(
          :rdv,
          starts_at: "2021-10-24", motif: motif, organisation: organisation
        )
      end
      let!(:participation2) do
        create(
          :participation,
          rdv_context: rdv_context, rdv: rdv_orientation2, applicant: applicant, status: "seen",
          created_at: "2021-10-23"
        )
      end

      let!(:rdv_context2) do
        create(
          :rdv_context, status: "invitation_pending", applicant: applicant, motif_category: category_accompagnement
        )
      end

      let!(:invitation_accompagnement) do
        create(:invitation, sent_at: "2021-11-20", format: "sms", rdv_context: rdv_context2)
      end

      it "shows all the contexts" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/RSA orientation/)
        expect(response.body).to match(/RSA accompagnement/)
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
        expect(response.body).to match(/Invitation en attente de réponse/)
        expect(response.body).to match(/RSA Orientation sur site/)
        expect(response.body).not_to match(/Convoqué par/)
      end

      context "when one rdv is a convocation" do
        before { rdv_orientation1.update!(convocable: true) }

        let!(:notification) do
          create(
            :notification,
            participation: participation, event: "participation_created", format: "sms",
            sent_at: 2.days.ago
          )
        end

        it "shows the convocation formats" do
          get :show, params: show_params

          expect(response.body).to match(/Convoqué par/)
          expect(response.body).to include("SMS 📱")
          expect(response.body).not_to include("Email 📧")
        end

        context "when the rdv is in the future" do
          before { rdv_orientation1.update! starts_at: 2.days.from_now }

          it "shows the courrier generation button" do
            get :show, params: show_params

            expect(response.body).to include("<i class=\"fas fa-file-pdf\"></i> Courrier")
          end
        end

        context "when the rdv is passed" do
          context "when the participation is revoked" do
            before { participation.update! status: "revoked" }

            it "shows the courrier generation button" do
              get :show, params: show_params

              expect(response.body).to include("<i class=\"fas fa-file-pdf\"></i> Courrier")
            end
          end

          context "when the rdv participation is seen" do
            before { participation.update! status: "seen" }

            it "does not show the courrier generation button" do
              get :show, params: show_params

              expect(response.body).not_to include("<i class=\"fas fa-file-pdf\"></i> Courrier")
            end
          end
        end
      end

      context "when there is no matching configuration for a rdv_context" do
        let!(:configuration) do
          create(:configuration, motif_category: category_accompagnement, invitation_formats: %w[sms email])
        end

        let!(:organisation) do
          create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                                department_id: department.id, configurations: [configuration])
        end

        let!(:rdv_context) do
          create(:rdv_context, status: "rdv_seen", applicant: applicant, motif_category: category_orientation)
        end

        it "does not display the context" do
          get :show, params: show_params

          expect(response).to be_successful
          expect(response.body).to match(/InvitationBlock/)
          expect(response.body).not_to match(/RSA orientation/)
        end
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
    let!(:rdv_context1) { build(:rdv_context, motif_category: category_orientation, status: "rdv_seen") }

    let!(:applicant2) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Baer", rdv_contexts: [rdv_context2]
      )
    end
    let!(:rdv_context2) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:applicant3) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Darmon", rdv_contexts: [rdv_context3]
      )
    end
    let!(:rdv_context3) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:archived_applicant) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Barthelemy", rdv_contexts: [rdv_context4],
        archived_at: 2.days.ago
      )
    end
    let!(:rdv_context4) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:index_params) { { organisation_id: organisation.id, motif_category: category_orientation } }

    render_views

    before do
      sign_in(agent)
    end

    it "returns a list of applicants" do
      get :index, params: index_params

      expect(response).to be_successful
      expect(response.body).to match(/Chabat/)
      expect(response.body).to match(/Baer/)
      expect(response.body).to match(/Darmon/)
      expect(response.body).not_to match(/Barthelemy/)
    end

    it "does not display the configure organisation option" do
      get :index, params: index_params

      expect(response.body).not_to match(/Configurer l'organisation/)
    end

    context "when there is all types of rdv_contexts statuses" do
      before do
        RdvContext.statuses.each_key do |status|
          create(:rdv_context, motif_category: category_orientation,
                               status: status,
                               applicant: create(:applicant, organisations: [organisation], department: department))
        end
      end

      it "displays all statuses in the filter list" do
        get :index, params: index_params.merge(motif_category_id: category_orientation.id)
        RdvContext.statuses.each_key do |status|
          expect(response.body).to match(/"#{status}"/)
        end
      end
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

    context "when a context is specified" do
      let!(:rdv_context2) { build(:rdv_context, motif_category: category_accompagnement, status: "invitation_pending") }
      let!(:configuration) { create(:configuration, motif_category: category_accompagnement) }

      it "returns the list of applicants in the current context" do
        get :index, params: index_params.merge(motif_category_id: category_accompagnement.id)

        expect(response).to be_successful
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).to match(/Baer/)
      end
    end

    context "when archived applicants only" do
      let!(:index_params) { { organisation_id: organisation.id, applicants_scope: "archived" } }

      it "returns the list of archived applicants" do
        get :index, params: index_params

        expect(response).to be_successful
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
        expect(response.body).to match(/Barthelemy/)
      end
    end

    context "when a search query is specified" do
      let!(:index_params) do
        { organisation_id: organisation.id, search_query: "chabat", motif_category_id: category_orientation.id }
      end

      it "searches the applicants" do
        get :index, params: index_params
        expect(response.body).to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
      end
    end

    context "when a status is passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, status: "invitation_pending", motif_category_id: category_orientation.id }
      end

      it "filters by status" do
        get :index, params: index_params
        expect(response.body).to match(/Baer/)
        expect(response.body).not_to match(/Chabat/)
      end
    end

    context "when dates are passed" do
      let!(:invitation1) do
        create(
          :invitation, sent_at: Time.zone.parse("2022-06-01 12:00"), rdv_context: rdv_context1,
                       applicant: applicant
        )
      end
      let!(:invitation2) do
        create(
          :invitation, sent_at: Time.zone.parse("2022-06-08 12:00"), rdv_context: rdv_context2, applicant: applicant2
        )
      end
      let!(:invitation3) do
        create(
          :invitation, sent_at: Time.zone.parse("2022-06-15 12:00"), rdv_context: rdv_context3, applicant: applicant3
        )
      end

      context "for first invitations" do
        let!(:index_params) do
          { organisation_id: organisation.id, motif_category_id: category_orientation.id,
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
          create(:invitation, sent_at: Time.zone.parse("2022-06-19 12:00"),
                              rdv_context: rdv_context1, applicant: applicant)
        end
        let!(:invitation5) do
          create(:invitation, sent_at: Time.zone.parse("2022-06-16 12:00"),
                              rdv_context: rdv_context2, applicant: applicant2)
        end
        let!(:invitation6) do
          create(:invitation, sent_at: Time.zone.parse("2022-06-17 12:00"),
                              rdv_context: rdv_context3, applicant: applicant3)
        end

        let!(:index_params) do
          { organisation_id: organisation.id, motif_category: category_orientation,
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
        { organisation_id: organisation.id, action_required: "true", motif_category_id: category_orientation.id }
      end
      let!(:number_of_days_before_action_required) { 4 }

      context "when the invitation has been sent before the number of days before action required" do
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

    context "when filter_by_current_agent is passed" do
      let!(:index_params) do
        {
          organisation_id: organisation.id,
          filter_by_current_agent: "true",
          motif_category_id: category_orientation.id
        }
      end

      before { applicant.agents = [agent] }

      it "filters on the applicants assigned to the agent" do
        get :index, params: index_params
        expect(response.body).to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when the organisation convene applicants" do
      before do
        configuration.update!(convene_applicant: true)
        rdv_context2.update!(motif_category: category_accompagnement)
      end

      let!(:rdv) { create(:rdv) }
      let!(:participation) do
        create(
          :participation,
          rdv: rdv,
          applicant: applicant,
          status: "unknown",
          rdv_context: rdv_context1
        )
      end
      let!(:rdv2) { create(:rdv) }
      let!(:participation2) do
        create(
          :participation,
          rdv: rdv2,
          applicant: applicant,
          status: "unknown",
          rdv_context: rdv_context2
        )
      end
      let!(:notification) do
        create(
          :notification,
          participation: participation, event: "participation_created", sent_at: Time.zone.parse("20/12/2021 12:00")
        )
      end
      let!(:notification2) do
        create(
          :notification,
          participation: participation, event: "participation_updated", sent_at: Time.zone.parse("21/12/2021 12:00")
        )
      end
      let!(:notification3) do
        create(
          :notification,
          participation: participation2, event: "participation_created", sent_at: Time.zone.parse("25/12/2021 12:00")
        )
      end

      it "shows the last sent convocation on the current motif category" do
        get :index, params: index_params

        expect(response.body).to include("Dernière convocation envoyée le")
        expect(response.body).to include("20/12/2021")
        expect(response.body).not_to include("21/12/2021")
        expect(response.body).not_to include("25/12/2021")
      end
    end

    context "when department level" do
      let!(:index_params) { { department_id: department.id, motif_category_id: category_orientation.id } }

      it "renders the index page" do
        get :index, params: index_params

        expect(response.body).to match(/Chabat/)
        expect(response.body).to match(/Baer/)
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

  describe "#edit" do
    let!(:applicant) { create(:applicant, organisations: [organisation], department: department) }

    render_views

    before do
      sign_in(agent)
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
    let!(:applicant) { create(:applicant, organisations: [organisation], department: department) }
    let!(:update_params) do
      { id: applicant.id, organisation_id: organisation.id, applicant: { birth_date: "20/12/1988" } }
    end

    before do
      sign_in(agent)
    end

    context "when json request" do
      let(:update_params) do
        {
          applicant: {
            birth_date: "20/12/1988"
          },
          id: applicant.id,
          organisation_id: organisation.id,
          format: "json"
        }
      end

      before do
        allow(Applicants::Save).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(Applicants::Save).to receive(:call)
        post :update, params: update_params
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
        end

        it "does not call the service" do
          expect do
            post :update, params: update_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the update succeeds" do
        before do
          allow(Applicants::Save).to receive(:call)
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
          allow(Applicants::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "is not a success" do
          post :update, params: update_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["success"]).to eq(false)
        end

        it "renders the errors" do
          post :update, params: update_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to eq(["some error"])
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

        allow(Applicants::Save).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(Applicants::Save).to receive(:call)
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
        end

        it "does not call the service" do
          expect do
            patch :update, params: update_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the update succeeds" do
        before do
          allow(Applicants::Save).to receive(:call)
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
          allow(Applicants::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "renders the edit page" do
          patch :update, params: update_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
