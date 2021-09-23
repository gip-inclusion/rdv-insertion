describe ApplicantsController, type: :controller do
  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, departments: [department]) }

  describe "#create" do
    let(:applicant_params) do
      {
        applicant: {
          uid: "123xz", first_name: "john", last_name: "doe", email: "johndoe@example.com",
          affiliation_number: "1234", role: "conjoint"
        },
        department_id: department.id,
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
          department: department,
          applicant_data: applicant_params[:applicant],
          rdv_solidarites_session: request.session[:rdv_solidarites]
        )
      post :create, params: applicant_params
    end

    context "when not authorized" do
      let!(:another_department) { create(:department) }

      it "renders forbidden in the response" do
        post :create, params: applicant_params.merge(department_id: another_department.id)
        expect(response).to have_http_status(:forbidden)
      end

      it "does not call the service" do
        expect(CreateApplicant).not_to receive(:call)
        post :create, params: applicant_params.merge(department_id: another_department.id)
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
    let!(:search_params) { { applicants: { uids: [23] }, rdv_solidarites_page: 2, format: "json" } }
    let!(:applicant) { create(:applicant, department: department, uid: 23, email: "borisjohnson@gov.uk") }

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
          rdv_solidarites_page: '2',
          rdv_solidarites_session: request.session[:rdv_solidarites]
        )
      post :search, params: search_params
    end

    context "when not authorized" do
      let!(:another_department) { create(:department) }
      let!(:applicant) { create(:applicant, department: another_department, uid: 23) }

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

  describe "#index" do
    let!(:applicants) { department.applicants }
    let!(:applicant) { create(:applicant, department: department) }
    let!(:applicant2) { create(:applicant, department: department) }
    let!(:index_params) { { department_id: department.id } }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(RefreshApplicants).to receive(:call)
        .and_return(OpenStruct.new)
      allow(Applicant).to receive(:search_by_text)
        .and_return(applicants)
      allow(Applicant).to receive(:page)
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
        .with(
          applicants: department.applicants,
          rdv_solidarites_session: request.session[:rdv_solidarites],
          rdv_solidarites_page: nil
        )

      get :index, params: index_params
    end

    context "when a page is specified" do
      let!(:index_params) { { department_id: department.id, page: 4 } }

      it "retrieves the applicants from that page" do
        expect(Applicant).to receive(:page).with("4")

        get :index, params: index_params.merge(page: 4)
      end
    end

    context "when a search query is specified" do
      let!(:index_params) { { department_id: department.id, search_query: "coco" } }

      it "searches the applicants" do
        expect(Applicant).to receive(:search_by_text).with("coco")

        get :index, params: index_params
      end
    end
  end
end
