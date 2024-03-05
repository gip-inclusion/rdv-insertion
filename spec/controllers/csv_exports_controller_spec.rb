describe CsvExportsController do
  let!(:agent) { create(:agent) }
  let!(:csv_export) { create(:csv_export, agent: agent) }

  before do
    sign_in(agent)
  end

  describe "GET #show" do
    context "when the csv_export is valid and agent is authenticated" do
      it "redirects to the csv_export file" do
        get :show, params: { id: csv_export.id }
        expect(response).to redirect_to(/fichier_contact_test.csv/)
      end
    end
  end
end
