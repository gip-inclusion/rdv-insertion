RSpec.describe UserListUpload do
  subject { user_list_upload.save }

  let(:user_list_upload) do
    build(:user_list_upload,
          agent: agent,
          structure: department,
          user_list: raw_user_list)
  end

  let(:agent) { create(:agent) }
  let(:department) { create(:department) }
  let(:nir) { generate_random_nir }

  let(:raw_user_list) do
    [raw_user_row]
  end

  let!(:raw_user_row) do
    {
      "first_name" => "John  ",
      "last_name" => "Doe",
      "email" => "john@example.com",
      "phone_number" => "0612345678",
      "title" => "monsieur",
      "role" => "demandeur",
      "nir" => nir,
      "tags" => ["tag1  ", "  tag2"],
      "cnaf_data" => {
        "phone_number" => "0687654321",
        "email" => "john@cnaf.fr  ",
        "rights_opening_date" => "2024-01-01"
      }
    }
  end

  before do
    allow(UserPolicy).to receive(:restricted_user_attributes_for_organisations).and_return([])
  end

  describe "#format_user_list!" do
    it "formats the user list data" do
      subject

      expect(user_list_upload.user_list.first).to include(
        {
          "first_name" => "John",
          "last_name" => "Doe",
          "email" => "john@example.com",
          "phone_number" => "+33612345678",
          "nir" => nir,
          "title" => "monsieur",
          "role" => "demandeur",
          "tags" => %w[tag1 tag2],
          "cnaf_data" => {
            "phone_number" => "+33687654321",
            "email" => "john@cnaf.fr",
            "rights_opening_date" => "2024-01-01"
          }
        }
      )
    end

    it "removes blank attributes" do
      raw_user_row["referent_email"] = ""
      subject

      expect(user_list_upload.user_list.first).not_to have_key("referent_email")
    end

    it "removes not allowed attributes" do
      raw_user_row["some_attribute"] = "1234567890"
      subject

      expect(user_list_upload.user_list.first).not_to have_key("some_attribute")
    end

    describe "restricted attributes" do
      before do
        allow(user_list_upload).to receive(:restricted_user_attributes).and_return([:nir])
      end

      it "removes restricted attributes from the user list" do
        subject

        expect(user_list_upload.user_list.first).not_to have_key("nir")
      end
    end
  end

  describe "#remove_duplicates!" do
    let(:raw_user_list) do
      [raw_user_row, raw_user_row]
    end

    it "removes duplicate entries" do
      subject

      expect(user_list_upload.user_list.length).to eq(1)
    end
  end

  describe "#add_user_list_uid_to_users!" do
    it "adds unique user_list_uid to each entry" do
      subject

      expect(user_list_upload.user_list.first["user_list_uid"]).to be_present
      expect(user_list_upload.user_list.first["user_list_uid"]).to match(/^[0-9a-f-]{36}$/) # UUID format
    end
  end

  describe "#augment_user_list!" do
    let!(:existing_user) { create(:user, nir: generate_random_nir) }

    context "when matching by NIR" do
      let!(:raw_user_row) do
        {
          "first_name" => "John",
          "last_name" => "Doe",
          "nir" => existing_user.nir
        }
      end

      it "adds matching_user_id when NIR matches" do
        subject
        expect(user_list_upload.user_list.first["matching_user_id"]).to eq(existing_user.id)
      end
    end

    context "when matching by phone number and first name" do
      let!(:existing_user) { create(:user, first_name: "John", phone_number: "+33612345678") }
      let(:raw_user_row) do
        {
          "first_name" => "John",
          "phone_number" => "+33612345678"
        }
      end

      it "adds matching_user_id when phone and first name match" do
        subject
        expect(user_list_upload.user_list.first["matching_user_id"]).to eq(existing_user.id)
      end

      it "doesn't match when first names don't match" do
        existing_user.update!(first_name: "Jane")
        subject
        expect(user_list_upload.user_list.first["matching_user_id"]).to be_nil
      end
    end

    context "when matching by affiliation_number and role" do
      context "when the user is in the department" do
        let!(:existing_user) do
          create(
            :user,
            affiliation_number: "12345", role: "demandeur",
            organisations: [create(:organisation, department: department)]
          )
        end

        let(:raw_user_row) do
          {
            "first_name" => "John",
            "affiliation_number" => "12345",
            "role" => "demandeur"
          }
        end

        it "adds matching_user_id when affiliation_number and role match" do
          subject
          expect(user_list_upload.user_list.first["matching_user_id"]).to eq(existing_user.id)
        end

        it "doesn't match when role differs" do
          existing_user.update!(role: nil)
          subject
          expect(user_list_upload.user_list.first["matching_user_id"]).to be_nil
        end
      end

      context "when the user is not in the department" do
        let!(:other_department_user) do
          create(:user, affiliation_number: "12345", role: "demandeur")
        end

        it "doesn't match when the user is not in the department" do
          subject
          expect(user_list_upload.user_list.first["matching_user_id"]).to be_nil
        end
      end
    end

    context "when matching by email and first name" do
      let!(:existing_user) { create(:user, email: "john@example.com", first_name: "JOHN") }
      let(:raw_user_row) do
        {
          "first_name" => "John",
          "email" => "john@example.com"
        }
      end

      it "adds matching_user_id when email and first name match" do
        subject
        expect(user_list_upload.user_list.first["matching_user_id"]).to eq(existing_user.id)
      end

      it "matches on first word of compound first names" do
        existing_user.update!(first_name: "John Paul")
        subject
        expect(user_list_upload.user_list.first["matching_user_id"]).to eq(existing_user.id)
      end
    end

    context "when matching users by department_internal_id" do
      context "when the user is in the department" do
        let!(:department_user) do
          create(
            :user,
            department_internal_id: "DEP123", organisations: [create(:organisation, department: department)]
          )
        end

        let(:raw_user_row) do
          {
            "first_name" => "John",
            "department_internal_id" => "DEP123"
          }
        end

        it "finds users within the department" do
          subject
          expect(user_list_upload.user_list.first["matching_user_id"]).to eq(department_user.id)
        end
      end

      context "when the user is not in the department" do
        let!(:other_department_user) do
          create(:user, department_internal_id: "DEP123")
        end

        let(:raw_user_row) do
          {
            "first_name" => "John",
            "department_internal_id" => "DEP123"
          }
        end

        it "doesn't find users within the department" do
          subject
          expect(user_list_upload.user_list.first["matching_user_id"]).to be_nil
        end
      end
    end

    context "when no match is found" do
      let(:raw_user_row) do
        {
          "first_name" => "Unknown",
          "email" => "unknown@example.com",
          "phone_number" => "+33699999999"
        }
      end

      it "doesn't add matching_user_id" do
        subject
        expect(user_list_upload.user_list.first).not_to have_key("matching_user_id")
      end
    end
  end
end
