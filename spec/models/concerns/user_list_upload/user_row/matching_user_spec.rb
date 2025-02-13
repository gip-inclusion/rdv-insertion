RSpec.describe UserListUpload::UserRow::MatchingUser, type: :concern do
  describe "set matching user callbacks" do
    let(:user_list_upload) { create(:user_list_upload) }
    let(:department) { create(:department) }

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

    shared_examples "matches user correctly" do
      subject { user_row.save! }

      context "when matching by NIR" do
        let!(:matching_user) { create(:user, nir: "1234567890123") }

        it "sets the matching user" do
          subject
          expect(user_row.reload.matching_user).to eq(matching_user)
        end
      end

      context "when matching by email and first name" do
        let!(:matching_user) { create(:user, email: "john@example.com", first_name: "John") }

        it "sets the matching user" do
          subject
          expect(user_row.reload.matching_user).to eq(matching_user)
        end
      end

      context "when matching by department internal ID" do
        let(:organisation) { create(:organisation, department: department) }
        let!(:matching_user) do
          create(:user, department_internal_id: "ABC123", organisations: [organisation])
        end

        it "sets the matching user" do
          subject
          expect(user_row.reload.matching_user).to eq(matching_user)
        end

        context "when it is outside of the department" do
          let(:organisation) { create(:organisation, department: create(:department)) }

          it "does not set the matching user" do
            subject
            expect(user_row.reload.matching_user).to be_nil
          end
        end
      end

      context "when matching by affiliation number and role" do
        let(:organisation) { create(:organisation, department: department) }
        let!(:matching_user) do
          create(:user, affiliation_number: "1234567890", role: "demandeur", organisations: [organisation])
        end

        it "sets the matching user" do
          subject
          expect(user_row.reload.matching_user).to eq(matching_user)
        end

        context "when it is outside of the department" do
          let(:organisation) { create(:organisation, department: create(:department)) }

          it "does not set the matching user" do
            subject
            expect(user_row.reload.matching_user).to be_nil
          end
        end
      end

      context "when no matching user exists" do
        it "does not set a matching user" do
          subject
          expect(user_row.reload.matching_user).to be_nil
        end
      end
    end

    describe "set matching user on create" do
      context "when creating a new record" do
        let(:user_row) { user_list_upload.user_rows.build(user_row_attributes) }

        it "retrieves potential matching users from the user_list_upload" do
          expect(user_list_upload).to receive(:potential_matching_users_in_all_app).once.and_call_original
          expect(user_list_upload).to receive(:potential_matching_users_in_department).once.and_call_original
          user_row.save!
        end

        include_examples "matches user correctly"
      end
    end

    describe "set matching user on update" do
      context "when updating an existing record" do
        let!(:user_row) { user_list_upload.user_rows.create!(user_row_attributes) }

        it "does not retrieve the potential matching users from the user_list_upload" do
          expect(user_list_upload).not_to receive(:potential_matching_users_in_all_app)
          expect(user_list_upload).not_to receive(:potential_matching_users_in_department)
          user_row.save!
        end

        include_examples "matches user correctly"
      end
    end
  end
end
