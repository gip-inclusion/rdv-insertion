RSpec.describe UserListUpload::Row do
  let(:row) do
    described_class.new(
      row_data: row_data,
      user_list_upload: user_list_upload,
      matching_user: matching_user,
      resources_to_assign: resources_to_assign
    )
  end

  let(:row_data) do
    {
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      user_list_uid: "123"
    }
  end
  let(:user_list_upload) { create(:user_list_upload) }
  let(:matching_user) { nil }
  let(:resources_to_assign) { {} }

  describe "#user_attributes" do
    context "when there is no matching user" do
      it "returns row_data merged with creation origin attributes" do
        expect(row.user_attributes).to include(
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com",
          created_through: "rdv_insertion_upload_page",
          created_from_structure_type: user_list_upload.structure_type,
          created_from_structure_id: user_list_upload.structure_id
        )
      end
    end

    context "when there is a matching user" do
      let(:matching_user) { create(:user) }

      it "returns row_data without creation origin attributes" do
        expect(row.user_attributes).to include(
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com"
        )
        expect(row.user_attributes).not_to include(
          :created_through,
          :created_from_structure_type,
          :created_from_structure_id
        )
      end
    end

    context "when there is cnaf_data" do
      let(:row_data) do
        {
          first_name: "John",
          last_name: "Doe",
          cnaf_data: { birth_date: "1990-01-01" }
        }
      end

      it "merges cnaf_data with row_data" do
        expect(row.user_attributes).to include(birth_date: "1990-01-01")
      end
    end
  end

  describe "#changed_by_cnaf_data?" do
    context "when cnaf_data contains different values" do
      let(:row_data) do
        {
          first_name: "John",
          birth_date: "1990-01-01",
          cnaf_data: { birth_date: "1991-01-01" }
        }
      end

      it { expect(row.changed_by_cnaf_data?).to be true }
    end

    context "when cnaf_data contains same values" do
      let(:row_data) do
        {
          first_name: "John",
          birth_date: "1990-01-01",
          cnaf_data: { birth_date: "1990-01-01" }
        }
      end

      it { expect(row.changed_by_cnaf_data?).to be false }
    end
  end

  describe "associations methods" do
    let(:tag) { create(:tag) }
    let(:organisation) { create(:organisation) }
    let(:referent) { create(:agent) }
    let(:motif_category) { create(:motif_category) }
    let(:resources_to_assign) do
      {
        tags: [tag],
        organisation: organisation,
        referent: referent
      }
    end

    before do
      allow(user_list_upload).to receive(:motif_category).and_return(motif_category)
    end

    context "when there is no matching user" do
      it "returns assigned resources" do
        expect(row.tags).to eq([tag])
        expect(row.organisations).to eq([organisation])
        expect(row.referents).to eq([referent])
        expect(row.motif_categories).to eq([motif_category])
      end
    end

    context "when there is a matching user" do
      let(:existing_tag) { create(:tag) }
      let(:existing_organisation) { create(:organisation) }
      let(:existing_referent) { create(:agent) }
      let(:existing_motif_category) { create(:motif_category) }
      let(:matching_user) do
        create(
          :user,
          tags: [existing_tag],
          organisations: [existing_organisation],
          referents: [existing_referent],
          motif_categories: [existing_motif_category]
        )
      end

      it "merges existing and new resources" do
        expect(row.tags).to contain_exactly(existing_tag, tag)
        expect(row.organisations).to contain_exactly(existing_organisation, organisation)
        expect(row.referents).to contain_exactly(existing_referent, referent)
        expect(row.motif_categories).to contain_exactly(existing_motif_category, motif_category)
      end
    end
  end

  describe "#will_change_matching_user?" do
    context "when there is no matching user" do
      it { expect(row.will_change_matching_user?).to be false }
    end

    context "when there is a matching user" do
      let(:matching_user) do
        create(
          :user,
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com",
          motif_categories: [user_list_upload.motif_category]
        )
      end

      context "when user attributes changed" do
        before { row_data[:first_name] = "Jane" }

        it { expect(row.will_change_matching_user?).to be true }
      end

      context "when associations will change" do
        let(:resources_to_assign) { { organisation: create(:organisation) } }

        it { expect(row.will_change_matching_user?).to be true }
      end

      context "when nothing changes" do
        it { expect(row.will_change_matching_user?).to be false }
      end
    end
  end

  describe "#invitable?" do
    context "when user is not saved" do
      it { expect(row).not_to be_invitable }
    end

    context "when user is saved" do
      let(:saved_user) { create(:user) }

      before do
        row_data[:user_save_attempts] = [
          { created_at: 2.weeks.ago.to_s, success: true, errors: [], error_type: nil, user_id: saved_user.id }
        ]
        allow(saved_user).to receive(:can_be_invited_through_phone_or_email?).and_return(true)
        allow(user_list_upload).to receive(:saved_users).and_return([saved_user])
      end

      context "when user was not previously invited" do
        it { expect(row).to be_invitable }
      end

      context "when user was previously invited" do
        before do
          create(
            :invitation,
            user: saved_user,
            follow_up: create(:follow_up, motif_category: user_list_upload.motif_category),
            format: "email",
            created_at: 2.weeks.ago
          )
        end

        it { expect(row).not_to be_invitable }
      end

      context "when user cannot be invited through phone or email" do
        before do
          allow(saved_user).to receive(:can_be_invited_through_phone_or_email?).and_return(false)
        end

        it { expect(row).not_to be_invitable }
      end
    end
  end
end
