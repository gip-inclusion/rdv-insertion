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
        department_id: department.id
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

  describe "GET #index" do
    before do
      sign_in(agent)
    end

    context "when department does not exist" do
      it "returns an error" do
        expect do
          get :index, params: { department_id: "i-do-not-exist" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when agent does not belong to the department" do
      let(:other_department) { create(:department) }
      let(:agent) { create(:agent, departments: [other_department]) }

      it "redirects the agent" do
        get :index, params: { department_id: department.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent is authorized" do
      it "returns a success response" do
        get :index, params: { department_id: department.id }
        expect(response).to be_successful
      end
    end
  end

  describe "#search" do
    let!(:search_params) { { applicants: { uids: [23] }, page: 2 } }
    let!(:applicant) { create(:applicant, uid: 23, email: "borisjohnson@gov.uk") }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(UpdateApplicants).to receive(:call)
        .and_return(OpenStruct.new)
      allow(Applicant).to receive(:where)
        .with(uid: ['23'])
        .and_return([applicant])
    end

    it "calls the update service" do
      expect(UpdateApplicants).to receive(:call)
        .with(
          applicants: [applicant],
          page: '2',
          rdv_solidarites_session: request.session[:rdv_solidarites]
        )
      post :search, params: search_params
    end

    context "when the service succeeds" do
      before do
        allow(UpdateApplicants).to receive(:call)
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
        allow(UpdateApplicants).to receive(:call)
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
end
