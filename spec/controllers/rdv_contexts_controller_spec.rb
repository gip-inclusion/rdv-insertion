describe RdvContextsController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let(:applicant) { create(:applicant, organisations: [organisation]) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:configuration) do
    create(
      :configuration,
      motif_category: category_orientation,
      organisation: organisation, number_of_days_before_action_required: number_of_days_before_action_required
    )
  end
  let!(:number_of_days_before_action_required) { 6 }
  let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }

  before do
    sign_in(agent)
  end

  describe "#create" do
    let(:rdv_context_params) do
      {
        rdv_context: { applicant_id: applicant.id, motif_category_id: category_orientation.id },
        organisation_id: organisation.id
      }
    end
    let!(:rdv_context_count_before) { RdvContext.count }

    it "creates a new rdv_context" do
      post :create, params: rdv_context_params
      expect(RdvContext.count).to eq(rdv_context_count_before + 1)
      expect(RdvContext.last.applicant).to eq(applicant)
      expect(RdvContext.last.motif_category).to eq(category_orientation)
    end

    context "when not authorized" do
      let!(:another_organisation) { create(:organisation) }
      let(:applicant) { create(:applicant, organisations: [another_organisation]) }

      it "raises an error" do
        expect do
          post :create, params: rdv_context_params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when te creation fails" do
      let!(:rdv_context) { create(:rdv_context, motif_category: category_orientation, applicant: applicant) }

      it "opens an error modal" do
        post :create, params: rdv_context_params

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to match(/replace/)
        expect(response.body).to match(/remote_modal/)
      end
    end

    context "when html request" do
      it "redirects to the applicant show page with the right anchor" do
        post :create, params: rdv_context_params, format: :html

        expect(response).to redirect_to(
          organisation_applicant_path(organisation, applicant, anchor: "rdv_context_#{RdvContext.last.id}")
        )
      end

      context "when department level" do
        let(:rdv_context_params) do
          {
            rdv_context: { applicant_id: applicant.id, motif_category_id: category_orientation.id },
            department_id: department.id
          }
        end

        it "redirects to the right path" do
          post :create, params: rdv_context_params, format: :html

          expect(response).to redirect_to(
            department_applicant_path(department, applicant, anchor: "rdv_context_#{RdvContext.last.id}")
          )
        end
      end
    end

    context "when turbo request" do
      it "replace the create rdv_context button" do
        post :create, params: rdv_context_params, format: :turbo_stream

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to match(/replace/)
        expect(response.body).to match(/target="applicant_#{applicant.id}_motif_category_#{category_orientation.id}"/)
      end
    end
  end

  describe "#index" do
    let!(:category_accompagnement) do
      create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement")
    end
    let!(:applicant) do
      create(
        :applicant,
        created_at: Time.zone.parse("2023-03-10 12:30"),
        organisations: [organisation], last_name: "Chabat", rdv_contexts: [rdv_context1]
      )
    end
    let!(:rdv_context1) { build(:rdv_context, motif_category: category_orientation, status: "rdv_seen") }

    let!(:applicant2) do
      create(
        :applicant,
        created_at: Time.zone.parse("2023-04-10 12:30"),
        organisations: [organisation], last_name: "Baer", rdv_contexts: [rdv_context2]
      )
    end
    let!(:rdv_context2) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:applicant3) do
      create(
        :applicant,
        created_at: Time.zone.parse("2023-05-10 12:30"),
        organisations: [organisation], last_name: "Darmon", rdv_contexts: [rdv_context3]
      )
    end
    let!(:rdv_context3) { build(:rdv_context, motif_category: category_accompagnement, status: "invitation_pending") }
    let!(:configuration2) { create(:configuration, motif_category: category_accompagnement) }

    let!(:archived_applicant) do
      create(
        :applicant,
        organisations: [organisation], last_name: "Barthelemy", rdv_contexts: [rdv_context4]
      )
    end
    let!(:archive) { create(:archive, applicant: archived_applicant, department: department) }
    let!(:rdv_context4) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:index_params) { { organisation_id: organisation.id, motif_category_id: category_orientation.id } }

    render_views

    before do
      sign_in(agent)
    end

    it "returns a list of applicants in the current context" do
      get :index, params: index_params

      expect(response).to be_successful
      expect(response.body).to match(/Chabat/)
      expect(response.body).to match(/Baer/)
      expect(response.body).not_to match(/Darmon/)
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
                               applicant: create(:applicant, organisations: [organisation]))
        end
      end

      it "displays all statuses in the filter list except closed" do
        get :index, params: index_params.merge(motif_category_id: category_orientation.id)
        RdvContext.statuses.each_key do |status|
          if status == "closed"
            expect(response.body).not_to match(/"#{status}"/)
          else
            expect(response.body).to match(/"#{status}"/)
          end
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

    context "when invitations dates are passed" do
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
      let!(:rdv_context3) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

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
          create(:invitation, sent_at: Time.zone.parse("2022-06-17 12:00"),
                              rdv_context: rdv_context1, applicant: applicant)
        end
        let!(:invitation5) do
          create(:invitation, sent_at: Time.zone.parse("2022-06-20 12:00"),
                              rdv_context: rdv_context2, applicant: applicant2)
        end
        let!(:invitation6) do
          create(:invitation, sent_at: Time.zone.parse("2022-06-23 12:00"),
                              rdv_context: rdv_context3, applicant: applicant3)
        end

        let!(:index_params) do
          { organisation_id: organisation.id, motif_category_id: category_orientation.id,
            last_invitation_date_after: "21-06-2022", last_invitation_date_before: "24-06-2022" }
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

      context "when the invitation has been sent before the number of days before action required" do
        let!(:invitation) { create(:invitation, applicant: applicant2, rdv_context: rdv_context2, sent_at: 7.days.ago) }

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

      before { applicant.referents = [agent] }

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
end
