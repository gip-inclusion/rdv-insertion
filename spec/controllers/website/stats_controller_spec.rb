describe Website::StatsController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }

  describe "#index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "#show" do
    let!(:show_params_for_department) { { department_id_for_stats: department.id } }
    let!(:show_params_for_organisation) { { organisation_id_for_stats: organisation.id } }

    context "when for a department" do
      it "returns a success response" do
        get :show, params: show_params_for_department
        expect(response).to be_successful
      end
    end

    context "when for an organisation" do
      it "returns a success response" do
        get :show, params: show_params_for_organisation
        expect(response).to be_successful
      end
    end
  end

  describe "#deployment_map" do
    it "returns a success response" do
      get :deployment_map
      expect(response).to be_successful
    end
  end
end
