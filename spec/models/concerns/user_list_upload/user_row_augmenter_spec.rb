RSpec.describe UserListUpload::UserRowAugmenter, type: :concern do
  describe "augmentation callbacks" do
    let(:user_list_upload) { create(:user_list_upload) }
    let(:department) { create(:department) }
    let(:user_row) do
      build(:user_row, **user_row_attributes)
    end

    let(:user_row_attributes) do
      {
        first_name: "John",
        email: "john@example.com",
        nir: "1234567890123",
        department_internal_id: "ABC123",
        affiliation_number: "1234567890",
        role: "demandeur",
        phone_number: "+33612345678"
      }
    end

    before do
      allow(user_list_upload).to receive(:department).and_return(department)
    end
  end
end
