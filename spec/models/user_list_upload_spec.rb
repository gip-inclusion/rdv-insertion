RSpec.describe UserListUpload do
  describe "#user_rows_attributes=" do
    let(:user_list_upload) do
      create(
        :user_list_upload,
        user_rows_attributes: [
          { "email" => "user1@example.com" },
          { "email" => "user1@example.com" },
          { "email" => "user2@example.com" }
        ]
      )
    end

    it "removes duplicate row attributes before setting them" do
      expect(user_list_upload.user_rows.count).to eq(2)
      expect(user_list_upload.user_rows.pluck(:email)).to contain_exactly("user1@example.com", "user2@example.com")
    end
  end

  describe "#restricted_user_attributes" do
    let(:department) { create(:department, organisations: [cd_org, siae_org]) }
    let(:cd_org) { create(:organisation, organisation_type: "conseil_departemental") }
    let(:siae_org) { create(:organisation, organisation_type: "siae") }
    let(:agent) { create(:agent, organisations: [siae_org]) }

    it "returns restricted user attributes for the associated organisations" do
      user_list_upload = create(
        :user_list_upload,
        agent: agent, structure: department,
        user_rows_attributes: [
          {
            nir: generate_random_nir,
            department_internal_id: "1212242",
            first_name: "Jean",
            last_name: "Valjean"
          }
        ]
      )
      expect(user_list_upload.user_rows.count).to eq(1)
      user_row = user_list_upload.user_rows.first
      expect(user_row.nir).to be_nil
      expect(user_row.department_internal_id).to be_nil
      expect(user_row.first_name).to eq("Jean")
      expect(user_row.last_name).to eq("Valjean")
    end
  end

  describe "#referents_from_rows" do
    let(:organisation) { create(:organisation) }
    let(:agent) { create(:agent, organisations: [organisation]) }
    let(:user_list_upload) { create(:user_list_upload, agent:, structure: organisation) }
    let(:referent_from_organisation) { create(:agent, organisations: [organisation]) }
    let(:referent_from_outside_organisation) { create(:agent) }
    let!(:user_row) { create(:user_row, user_list_upload:, referent_email: referent_from_organisation.email) }
    let!(:user_row_from_outside_organisation) do
      create(:user_row, user_list_upload:, referent_email: referent_from_outside_organisation.email)
    end

    it "returns the referents from the rows scoped to the structure" do
      expect(user_list_upload.reload.referents_from_rows).to eq([referent_from_organisation])
    end
  end
end
