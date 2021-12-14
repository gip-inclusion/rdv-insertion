describe StatsController, type: :controller do
  describe "#index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    context "when a department is selected" do
      let(:search_params) { { department: "26" } }

      it "filters the data" do
        get :index, params: search_params
        expect(response).to be_successful
      end
    end
  end
end
