describe ApplicantsController, type: :controller do
  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:rdv_solidarites_organisation_id) { 52 }

  describe "#create" do
    let(:applicant_params) do
      {
        applicant: {
          uid: "123xz", first_name: "john", last_name: "doe", email: "johndoe@example.com",
          affiliation_number: "1234", role: "conjoint"
        },
        organisation_id: organisation.id,
        format: "json"
      }
    end

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(CreateApplicant).to receive(:call)
        .and_return(OpenStruct.new)
    end

    it "calls the service" do
      expect(CreateApplicant).to receive(:call)
        .with(
          organisation: organisation,
          applicant_data: applicant_params[:applicant],
          rdv_solidarites_session: request.session[:rdv_solidarites]
        )
      post :create, params: applicant_params
    end

    context "when not authorized" do
      let!(:another_organisation) { create(:organisation) }

      it "renders forbidden in the response" do
        post :create, params: applicant_params.merge(organisation_id: another_organisation.id)
        expect(response).to have_http_status(:forbidden)
      end

      it "does not call the service" do
        expect(CreateApplicant).not_to receive(:call)
        post :create, params: applicant_params.merge(organisation_id: another_organisation.id)
      end
    end

    context "when the creation succeeds" do
      let!(:applicant) { create(:applicant) }

      before do
        allow(CreateApplicant).to receive(:call)
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
        allow(CreateApplicant).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ['some error']))
      end

      it "is not a success" do
        post :create, params: applicant_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(false)
      end

      it "renders the errors" do
        post :create, params: applicant_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["errors"]).to eq(['some error'])
      end
    end
  end

  describe "#search" do
    let!(:search_params) { { applicants: { uids: [23] }, format: "json", organisation_id: organisation.id } }
    let!(:applicant) { create(:applicant, organisations: [organisation], uid: 23, email: "borisjohnson@gov.uk") }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(RefreshApplicants).to receive(:call)
        .and_return(OpenStruct.new)
      allow(Applicant).to receive(:where)
        .with(uid: ['23'])
        .and_return([applicant])
    end

    it "calls the update service" do
      expect(RefreshApplicants).to receive(:call)
        .with(
          applicants: [applicant],
          rdv_solidarites_session: request.session[:rdv_solidarites],
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id
        )
      post :search, params: search_params
    end

    context "when not authorized" do
      let!(:another_organisation) { create(:organisation) }
      let!(:agent) { create(:agent, organisations: [another_organisation]) }

      it "renders forbidden in the response" do
        post :search, params: search_params
        expect(response).to have_http_status(:forbidden)
      end

      it "does not call the service" do
        expect(RefreshApplicants).not_to receive(:call)
        post :search, params: search_params
      end
    end

    context "when the service succeeds" do
      before do
        allow(RefreshApplicants).to receive(:call)
          .and_return(OpenStruct.new(success?: true))
      end

      it "is a success" do
        post :search, params: search_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end

      it "renders the applicants updated" do
        post :search, params: search_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["applicants"].pluck("id")).to contain_exactly(applicant.id)
      end
    end

    context "when the service fails" do
      before do
        allow(RefreshApplicants).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ['some error']))
      end

      it "is still a success" do
        post :search, params: search_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end

      it "still renders the applicants" do
        post :search, params: search_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["applicants"].pluck("id")).to contain_exactly(applicant.id)
      end
    end
  end

  describe "#show" do
    let!(:applicant) { create(:applicant, organisations: [organisation]) }
    let!(:show_params) { { id: applicant.id, organisation_id: organisation.id } }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
    end

    it "renders the applicant page" do
      get :show, params: show_params

      expect(response).to be_successful
    end
  end

  describe "#index" do
    let!(:applicants) { organisation.applicants }
    let!(:applicant) { create(:applicant, organisations: [organisation]) }
    let!(:applicant2) { create(:applicant, organisations: [organisation]) }
    let!(:index_params) { { organisation_id: organisation.id } }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(RefreshApplicants).to receive(:call)
        .and_return(OpenStruct.new)
      allow(Applicant).to receive(:search_by_text)
        .and_return(applicants)
      allow(Applicant).to receive(:page)
        .and_return(applicants)
      allow(Applicant).to receive(:status)
        .and_return(applicants)
      allow(Applicant).to receive(:action_required)
        .and_return(applicants)
    end

    it "returns a list of applicants" do
      get :index, params: index_params

      expect(response).to be_successful
    end

    it "does not search applicants" do
      expect(Applicant).not_to receive(:search_by_text)

      get :index, params: index_params
    end

    it "calls the refresh service" do
      expect(RefreshApplicants).to receive(:call)

      get :index, params: index_params
    end

    context "when a page is specified" do
      let!(:index_params) { { organisation_id: organisation.id, page: 4 } }

      it "retrieves the applicants from that page" do
        expect(Applicant).to receive(:page).with("4")

        get :index, params: index_params.merge(page: 4)
      end
    end

    context "when a search query is specified" do
      let!(:index_params) { { organisation_id: organisation.id, search_query: "coco" } }

      it "searches the applicants" do
        expect(Applicant).to receive(:search_by_text).with("coco")

        get :index, params: index_params
      end
    end

    context "when a status is passed" do
      let!(:index_params) { { organisation_id: organisation.id, status: "rdv_pending" } }

      it "filters by status" do
        expect(Applicant).to receive(:status).with("rdv_pending")

        get :index, params: index_params
      end
    end

    context "when action_required is passed" do
      let!(:index_params) { { organisation_id: organisation.id, action_required: "true" } }

      it "filters by action required" do
        expect(Applicant).to receive(:action_required)

        get :index, params: index_params
      end
    end
  end

  describe "#update" do
    let!(:applicant) { create(:applicant, organisations: [organisation], status: "invitation_pending") }
    let!(:update_params) { { id: applicant.id, organisation_id: organisation.id, applicant: { status: "resolved" } } }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
    end

    context "when json request" do
      it "updates the applicant status" do
        patch :update, params: update_params, as: :json
        applicant.reload
        expect(applicant.status).to eq("resolved")
      end

      context "when it fails" do
        before do
          allow(applicant).to receive(:update)
            .and_return(false)
          allow(applicant).to receive(:errors)
            .and_return('some error')
        end

        it "stores the errors" do
          patch :update, params: update_params
          applicant.reload
          expect(applicant.errors).to eq("some error")
        end
      end
    end

    context "when html request" do
      let!(:update_params) do
        { id: applicant.id, organisation_id: organisation.id,
          applicant: { first_name: "Alain", last_name: "Deloin", phone_number_formatted: "0123456789" } }
      end

      before do
        sign_in(agent)
        set_rdv_solidarites_session
        allow(UpdateApplicant).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(UpdateApplicant).to receive(:call)
          .with(
            applicant: applicant,
            applicant_data: update_params[:applicant],
            rdv_solidarites_session: request.session[:rdv_solidarites]
          )
        patch :update, params: update_params
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
          set_rdv_solidarites_session
        end

        it "does not call the service" do
          expect(UpdateApplicant).not_to receive(:call)
          patch :update, params: update_params.merge(organisation_id: another_organisation.id)
        end
      end

      context "when the update succeeds" do
        before do
          allow(UpdateApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: true, applicant: applicant))
        end

        it "is redirects to the show page" do
          patch :update, params: update_params
          expect(response).to redirect_to(organisation_applicant_path(organisation, applicant))
        end
      end

      context "when the creation fails" do
        before do
          allow(UpdateApplicant).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ['some error']))
        end

        it "is renders the edit page" do
          patch :update, params: update_params
          expect(response).to be_successful
        end
      end
    end
  end
end
