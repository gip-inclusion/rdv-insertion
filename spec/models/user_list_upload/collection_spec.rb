RSpec.describe UserListUpload::Collection do
  let(:user_list_upload) { create(:user_list_upload) }
  let(:collection) { described_class.new(user_list_upload: user_list_upload) }

  let!(:user_row1) do
    create(
      :user_row,
      user_list_upload: user_list_upload,
      matching_user:
    )
  end

  let!(:user_row2) do
    create(
      :user_row,
      user_list_upload: user_list_upload,
      first_name: "Jane",
      last_name: "Smith",
      email: "jane@example.com",
      phone_number: "9876543210",
      affiliation_number: "XYZ789"
    )
  end

  let!(:matching_user) do
    create(
      :user,
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      phone_number: "+33102020101",
      affiliation_number: "ABC123"
    )
  end

  describe "#update_rows" do
    it "updates existing rows without creating new ones" do
      rows_data = [
        { id: user_row1.id, first_name: "Updated Name 1" },
        { id: user_row2.id, first_name: "Updated Name 2" }
      ]

      expect do
        collection.update_rows(rows_data)
      end.not_to change(UserListUpload::UserRow, :count)

      user_row1.reload
      user_row2.reload
      expect(user_row1.first_name).to eq("Updated Name 1")
      expect(user_row2.first_name).to eq("Updated Name 2")
    end
  end

  describe "#save" do
    it "updates existing rows without creating new ones" do
      user_row1.first_name = "Modified Name 1"
      user_row2.first_name = "Modified Name 2"

      expect do
        collection.save([user_row1, user_row2])
      end.not_to change(UserListUpload::UserRow, :count)

      user_row1.reload
      user_row2.reload
      expect(user_row1.first_name).to eq("Modified Name 1")
      expect(user_row2.first_name).to eq("Modified Name 2")
    end

    it "formats attributes before saving" do
      expect(user_row1).to receive(:format_attributes)
      expect(user_row2).to receive(:format_attributes)

      collection.save([user_row1, user_row2])
    end
  end

  describe "#mark_selected_rows_for_user_save!" do
    it "marks only selected rows for user save" do
      collection.mark_selected_rows_for_user_save!([user_row1.id])

      user_row1.reload
      user_row2.reload
      expect(user_row1).to be_selected_for_user_save
      expect(user_row2).not_to be_selected_for_user_save
    end
  end

  describe "#mark_selected_rows_for_invitation!" do
    it "marks only selected rows for invitation" do
      collection.mark_selected_rows_for_invitation!([user_row2.id])

      user_row1.reload
      user_row2.reload
      expect(user_row1).not_to be_selected_for_invitation
      expect(user_row2).to be_selected_for_invitation
    end
  end

  describe "#search!" do
    it "finds users by first name" do
      collection.search!("john")
      expect(collection.count).to eq(1)
      expect(collection.user_rows).to include(user_row1)
    end

    it "finds users by last name" do
      collection.search!("smith")
      expect(collection.count).to eq(1)
      expect(collection.user_rows).to include(user_row2)
    end

    it "finds users by email" do
      collection.search!("jane@example")
      expect(collection.count).to eq(1)
      expect(collection.user_rows).to include(user_row2)
    end

    it "finds users by phone number" do
      collection.search!("020201")
      expect(collection.count).to eq(1)
      expect(collection.user_rows).to include(user_row1)
    end

    it "finds users by affiliation number" do
      collection.search!("xyz")
      expect(collection.count).to eq(1)
      expect(collection.user_rows).to include(user_row2)
    end

    it "is case insensitive" do
      collection.search!("JOHN")
      expect(collection.count).to eq(1)
      expect(collection.user_rows).to include(user_row1)
    end

    it "returns empty collection when no matches found" do
      collection.search!("nonexistent")
      expect(collection.count).to eq(0)
      expect(collection.user_rows).to be_empty
    end
  end

  describe "#sort_by!" do
    it "sorts by first_name asc" do
      collection.sort_by!(sort_by: "first_name", sort_direction: "asc")
      expect(collection.user_rows.first).to eq(user_row2) # Jane
      expect(collection.user_rows.last).to eq(user_row1)  # John
    end

    it "sorts by first_name desc" do
      collection.sort_by!(sort_by: "first_name", sort_direction: "desc")
      expect(collection.user_rows.first).to eq(user_row1) # John
      expect(collection.user_rows.last).to eq(user_row2)  # Jane
    end
  end
end
