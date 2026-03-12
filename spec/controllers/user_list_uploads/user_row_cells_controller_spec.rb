describe UserListUploads::UserRowCellsController do
  let!(:agent) { create(:agent) }
  let!(:user_list_upload) { create(:user_list_upload, agent: agent) }
  let!(:user_row) { create(:user_row, user_list_upload: user_list_upload) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#edit" do
    subject do
      get :edit, params: {
        user_list_upload_id: user_list_upload.id,
        user_row_id: user_row.id,
        attribute: attribute,
        format: "turbo_stream"
      }
    end

    context "when the attribute is not editable" do
      let(:attribute) { "nir" }

      it "renders an error modal with a 422 status" do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("n&#39;est pas editable")
      end
    end
  end
end
