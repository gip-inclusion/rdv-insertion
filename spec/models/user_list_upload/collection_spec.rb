RSpec.describe UserListUpload::Collection do
  let(:user_list_upload) do
    create(
      :user_list_upload,
      user_list: [
        { first_name: "John", last_name: "Doe", email: "john@example.com" },
        { first_name: "Jane", last_name: "Smith", email: "jane@example.com" }
      ]
    )
  end
  let(:uid1) { user_list_upload.user_list.first["user_list_uid"] }
  let(:uid2) { user_list_upload.user_list.last["user_list_uid"] }
  let(:collection) { described_class.new(user_list_upload: user_list_upload) }

  describe "#update_rows" do
    it "updates multiple rows and saves the changes" do
      rows_data = {
        uid1 => { first_name: "Johnny" },
        uid2 => { first_name: "Janet" }
      }

      collection.update_rows(rows_data)

      expect(user_list_upload.reload.user_list).to include(
        hash_including("first_name" => "Johnny"),
        hash_including("first_name" => "Janet")
      )
    end
  end

  describe "#user_rows_with_errors" do
    it "returns rows with invalid users" do
      allow(collection.user_rows.first.user).to receive(:valid?).and_return(false)
      allow(collection.user_rows.last.user).to receive(:valid?).and_return(true)

      expect(collection.user_rows_with_errors).to contain_exactly(collection.user_rows.first)
    end
  end

  describe "#sort_by!" do
    it "sorts rows by the given attribute in ascending order" do
      collection.sort_by!(sort_by: :first_name, sort_direction: "asc")

      expect(collection.user_rows.map(&:first_name)).to eq(%w[Jane John])
    end

    it "sorts rows by the given attribute in descending order" do
      collection.sort_by!(sort_by: :first_name, sort_direction: "desc")

      expect(collection.user_rows.map(&:first_name)).to eq(%w[John Jane])
    end

    it "places nil values at the end" do
      user_list_upload.user_list.first["first_name"] = nil
      collection.sort_by!(sort_by: :first_name, sort_direction: "asc")

      expect(collection.user_rows.map(&:first_name)).to eq(["Jane", nil])
    end
  end

  describe "#search!" do
    it "filters rows by searchable attributes" do
      collection.search!("john")

      expect(collection.count).to eq(1)
      expect(collection.user_rows.first.email).to eq("john@example.com")
    end

    it "searches case-insensitively" do
      collection.search!("JOHN")

      expect(collection.count).to eq(1)
      expect(collection.user_rows.first.email).to eq("john@example.com")
    end

    it "searches across all searchable attributes" do
      collection.search!("smith")

      expect(collection.count).to eq(1)
      expect(collection.user_rows.first.email).to eq("jane@example.com")
    end
  end

  describe "#mark_selected_rows_for_user_save!" do
    it "marks selected rows for user save" do
      collection.mark_selected_rows_for_user_save!([uid1])

      expect(user_list_upload.user_list.first["marked_for_user_save"]).to be true
      expect(user_list_upload.user_list.last["marked_for_user_save"]).to be_nil
    end
  end

  describe "#mark_selected_rows_for_invitation!" do
    it "marks selected rows for invitation" do
      collection.mark_selected_rows_for_invitation!([uid1])

      expect(user_list_upload.user_list.first["marked_for_invitation"]).to be true
      expect(user_list_upload.user_list.last["marked_for_invitation"]).to be_nil
    end
  end

  describe "#update_row" do
    it "updates a single row and saves the changes" do
      collection.update_row(uid1, { first_name: "Johnny" })

      expect(user_list_upload.reload.user_list).to include(
        hash_including("first_name" => "Johnny"),
        hash_including("first_name" => "Jane")
      )
    end

    it "does nothing when row uid is not found" do
      collection.update_row("non_existent_uid", { first_name: "Johnny" })

      expect(user_list_upload.reload.user_list.first["first_name"]).to eq("John")
    end
  end

  describe "#build_user_rows" do
    let(:matching_user) { create(:user) }
    let(:referent) { create(:agent) }
    let(:tag1) { create(:tag, value: "tag1") }
    let(:tag2) { create(:tag, value: "tag2") }
    let(:organisation) { create(:organisation) }

    let!(:user_list_upload) do
      create(
        :user_list_upload,
        user_list: [row_data]
      )
    end

    let!(:row_data) do
      {
        first_name: "John",
        matching_user_id: matching_user.id,
        saved_user_id: matching_user.id,
        referent_email: referent.email,
        tags: [tag1.value, tag2.value],
        assigned_organisation_id: organisation.id
      }
    end

    let(:other_organisation) { create(:organisation) }

    before do
      allow(user_list_upload).to receive(:matching_users).and_return([matching_user])
      allow(user_list_upload).to receive(:referents_from_rows).and_return([referent])
      allow(user_list_upload).to receive(:tags_from_rows).and_return([tag1, tag2])
      allow(user_list_upload).to receive(:organisations).and_return([organisation, other_organisation])
    end

    it "assigns matching user" do
      expect(collection.user_rows.first.matching_user).to eq(matching_user)
    end

    it "assigns referent" do
      expect(collection.user_rows.first.referent_to_assign).to eq(referent)
    end

    it "assigns tags" do
      expect(collection.user_rows.first.tags_to_assign).to contain_exactly(tag1, tag2)
    end

    describe "organisation assignment" do
      it "assigns organisation by ID" do
        expect(collection.user_rows.first.organisation_to_assign).to eq(organisation)
      end

      context "when organisation search terms are provided" do
        before do
          user_list_upload.update!(
            user_list: [
              {
                first_name: "John",
                assigned_organisation_id: nil,
                organisation_search_terms: other_organisation.name.downcase
              }
            ]
          )
        end

        it "assigns organisation by search terms" do
          expect(collection.user_rows.first.organisation_to_assign).to eq(other_organisation)
        end
      end

      context "when no organisation matches" do
        before do
          user_list_upload.update!(
            user_list: [
              {
                first_name: "John",
                assigned_organisation_id: nil,
                organisation_search_terms: "non_existent"
              }
            ]
          )
        end

        it "returns nil" do
          expect(collection.user_rows.first.organisation_to_assign).to be_nil
        end
      end

      context "when there is only one organisation" do
        before do
          allow(user_list_upload).to receive(:organisations).and_return([organisation])
        end

        it "assigns organisation" do
          expect(collection.user_rows.first.organisation_to_assign).to eq(organisation)
        end
      end
    end
  end
end
