describe UserListUpload::UserRow do
  let(:user_row) { create(:user_row, user_list_upload:) }
  let(:user_list_upload) { create(:user_list_upload) }

  describe "#changed_by_cnaf_data?" do
    context "when cnaf_data is empty" do
      before { user_row.cnaf_data = {} }

      it { expect(user_row).not_to be_changed_by_cnaf_data }
    end

    context "when cnaf_data contains different values" do
      before do
        user_row.email = "old@example.com"
        user_row.cnaf_data = { "email" => "new@example.com" }
      end

      it { expect(user_row).to be_changed_by_cnaf_data }
    end

    context "when cnaf_data contains landline phone number" do
      context "when phone number is not set" do
        before do
          user_row.phone_number = nil
          user_row.cnaf_data = { "phone_number" => "0123456789" }
          user_row.format_attributes
        end

        it { expect(user_row).to be_changed_by_cnaf_data }
      end

      context "when phone number is set to a mobile phone number" do
        before do
          user_row.phone_number = "0612345678"
          user_row.cnaf_data = { "phone_number" => "0123456789" }
          user_row.format_attributes
        end

        it { expect(user_row).not_to be_changed_by_cnaf_data }
      end
    end

    context "when cnaf_data contains mobile phone number" do
      before do
        user_row.phone_number = "0723456789"
        user_row.cnaf_data = { "phone_number" => "0623456789" }
        user_row.format_attributes
      end

      it { expect(user_row).to be_changed_by_cnaf_data }
    end

    context "when cnaf_data contains same values" do
      before do
        user_row.email = "same@example.com"
        user_row.cnaf_data = { "email" => "same@example.com" }
      end

      it { expect(user_row).not_to be_changed_by_cnaf_data }
    end

    context "when there is a matching user" do
      let(:matching_user) { create(:user, email: "john.doe@example.com") }
      let(:user_row) { create(:user_row, matching_user: matching_user) }

      context "when cnaf_data contains different values" do
        before do
          user_row.cnaf_data = { "email" => "new@example.com" }
        end

        it { expect(user_row).to be_changed_by_cnaf_data }
      end

      context "when cnaf_data contains same values" do
        before do
          user_row.cnaf_data = { "email" => "john.doe@example.com" }
        end

        it { expect(user_row).not_to be_changed_by_cnaf_data }
      end
    end
  end

  describe "#tags" do
    let(:matching_user) { create(:user, tags: [existing_tag]) }
    let(:existing_tag) { create(:tag) }
    let(:new_tag) { create(:tag) }
    let(:user_row) { create(:user_row, user_list_upload:, matching_user: matching_user) }

    before do
      user_row.tag_values = [new_tag.value]
      allow(user_row.user_list_upload).to receive(:tags_from_rows).and_return([new_tag])
    end

    it "combines matching_user tags and assigned tags" do
      expect(user_row.tags).to contain_exactly(existing_tag, new_tag)
    end

    context "when no matching user" do
      let(:user_row) { create(:user_row, user_list_upload:) }

      it "returns only assigned tags" do
        expect(user_row.tags).to contain_exactly(new_tag)
      end
    end
  end

  describe "#organisations" do
    let(:user_row) { create(:user_row, user_list_upload:, matching_user:) }
    let(:matching_user) { create(:user, organisations: [existing_org]) }
    let(:existing_org) { create(:organisation) }
    let(:new_org) { create(:organisation, name: "new_org") }
    let(:user_list_upload) { create(:user_list_upload) }

    context "when there is only one organisation" do
      before do
        allow(user_list_upload).to receive(:organisations).and_return([new_org])
      end

      it "combines matching_user organisations and assigned organisation" do
        expect(user_row.organisations).to contain_exactly(existing_org, new_org)
      end

      context "when no matching user" do
        let(:user_row) { create(:user_row, user_list_upload:) }

        it "returns only assigned organisation" do
          expect(user_row.organisations).to contain_exactly(new_org)
        end
      end
    end

    context "when there is more than one organisation" do
      before do
        allow(user_list_upload).to receive(:organisations).and_return([existing_org, new_org])
      end

      context "when no organisation information is provided" do
        let(:user_row) { create(:user_row, user_list_upload:, matching_user: nil) }

        it "returns no organisation" do
          expect(user_row.organisations).to be_empty
        end
      end

      context "when organisation_search_terms is provided" do
        let(:user_row) do
          create(:user_row, user_list_upload:, matching_user: nil, organisation_search_terms: "new_org")
        end

        it "returns only assigned organisation" do
          expect(user_row.organisations).to contain_exactly(new_org)
        end

        context "if the search term does not match" do
          let(:user_row) do
            create(:user_row, user_list_upload:, matching_user: nil, organisation_search_terms: "something")
          end

          it "returns no organisation" do
            expect(user_row.organisations).to be_empty
          end
        end
      end

      context "when organisation_id is provided" do
        let(:user_row) do
          create(:user_row, user_list_upload:, matching_user: nil, assigned_organisation_id: new_org.id)
        end

        it "returns only assigned organisation" do
          expect(user_row.organisations).to contain_exactly(new_org)
        end
      end
    end
  end

  describe "#referents" do
    let(:matching_user) { create(:user, referents: [existing_referent]) }
    let(:existing_referent) { create(:agent) }
    let(:new_referent) { create(:agent) }
    let(:user_row) { create(:user_row, user_list_upload:, matching_user:, referent_email: new_referent.email) }

    before do
      allow(user_list_upload).to receive(:referents_from_rows).and_return([new_referent])
    end

    it "combines matching_user referents and assigned referent" do
      expect(user_row.referents).to contain_exactly(existing_referent, new_referent)
    end

    context "when no matching user" do
      let(:user_row) { create(:user_row, user_list_upload:, matching_user: nil, referent_email: new_referent.email) }

      it "returns only assigned referent" do
        expect(user_row.referents).to contain_exactly(new_referent)
      end
    end

    context "when referent_email is not provided" do
      let(:user_row) { create(:user_row, user_list_upload:, matching_user: nil, referent_email: nil) }

      it "returns no referent" do
        expect(user_row.referents).to be_empty
      end
    end

    context "when referent_email does not match any referent" do
      let(:user_row) { create(:user_row, user_list_upload:, matching_user: nil, referent_email: "unknown@example.com") }

      it "returns no referent" do
        expect(user_row.referents).to be_empty
      end
    end
  end

  describe "#motif_categories" do
    let(:matching_user) { create(:user) }
    let(:user_row) { create(:user_row, user_list_upload:, matching_user:) }
    let(:existing_category) { create(:motif_category) }
    let(:new_category) { create(:motif_category) }

    before do
      allow(matching_user).to receive(:motif_categories).and_return([existing_category])
      allow(user_list_upload).to receive(:motif_category).and_return(new_category)
    end

    it "combines matching_user categories and assigned category" do
      expect(user_row.motif_categories).to contain_exactly(existing_category, new_category)
    end

    context "when no matching user" do
      let(:user_row) { create(:user_row, user_list_upload:) }

      it "returns only assigned category" do
        expect(user_row.motif_categories).to contain_exactly(new_category)
      end
    end
  end

  describe "#invitable?" do
    let(:saved_user) { create(:user) }
    let(:motif_category) { create(:motif_category) }
    let(:user_row) do
      create(:user_row, user_list_upload:, user_save_attempts: [user_save_attempt])
    end

    let(:user_save_attempt) { create(:user_save_attempt, user: saved_user) }

    before do
      allow(saved_user).to receive(:can_be_invited_through_phone_or_email?).and_return(true)
      allow(user_row.user_list_upload).to receive(:motif_category).and_return(motif_category)
    end

    it { expect(user_row).to be_invitable }

    context "when user was previously invited" do
      context "when invitation is recent" do
        before do
          create(
            :invitation,
            :delivered,
            user: saved_user,
            created_at: 2.weeks.ago,
            format: "email",
            follow_up: create(:follow_up, motif_category:)
          )
        end

        it { expect(user_row).to be_invitable }
      end

      context "when invitation is old" do
        before do
          create(
            :invitation,
            user: saved_user, created_at: 2.months.ago, format: "email",
            follow_up: create(:follow_up, motif_category:)
          )
        end

        it { expect(user_row).to be_invitable }
      end

      context "when invitation is not on the same motif category" do
        before do
          create(
            :invitation,
            user: saved_user, created_at: 2.weeks.ago, format: "email",
            follow_up: create(:follow_up, motif_category: create(:motif_category))
          )
        end

        it { expect(user_row).to be_invitable }
      end
    end

    context "when user cannot be invited through phone or email" do
      before do
        allow(saved_user).to receive(:can_be_invited_through_phone_or_email?).and_return(false)
      end

      it { expect(user_row).not_to be_invitable }
    end
  end

  describe "#format_attributes" do
    let!(:user_row) do
      build(
        :user_row,
        phone_number: "0612345678",
        nir: "123456789",
        title: "monsieur",
        role: "unknown",
        tag_values: [" tag1 ", "tag2 "],
        cnaf_data: {
          "phone_number" => "0687654321",
          "email" => "test@example.com"
        }
      )
    end

    before do
      allow(NirHelper).to receive(:format_nir).and_return("1234567890123")
      user_row.save
    end

    it "formats phone number" do
      expect(user_row.phone_number).to eq("+33612345678")
    end

    it "formats NIR" do
      expect(user_row.nir).to eq("1234567890123")
    end

    it "formats title" do
      expect(user_row.title).to eq("monsieur")
    end

    it "formats role" do
      expect(user_row.role).to be_nil
    end

    it "formats tag values" do
      expect(user_row.reload.tag_values).to eq(%w[tag1 tag2])
    end

    it "formats cnaf data" do
      expect(user_row.reload.cnaf_data).to include(
        "phone_number" => "+33687654321",
        "email" => "test@example.com"
      )
    end
  end

  describe "#nullify_edited_to_nil_values" do
    let!(:matching_user) { create(:user, phone_number: "0612345678", email: "test@example.com") }

    it "nullifies edited to nil values" do
      create(
        :user_row,
        matching_user: matching_user,
        phone_number: "[EDITED TO NULL]",
        email: "[EDITED TO NULL]",
        affiliation_number: "[EDITED TO NULL]"
      )
      user_row = described_class.last
      expect(user_row.phone_number).to eq("[EDITED TO NULL]")
      expect(user_row.email).to eq("[EDITED TO NULL]")
      expect(user_row.affiliation_number).to eq("[EDITED TO NULL]")
      expect(user_row.user.phone_number).to be_nil
      expect(user_row.user.email).to be_nil
      expect(user_row.user.affiliation_number).to be_nil
    end
  end

  describe "status methods" do
    let(:user_list_upload) { create(:user_list_upload) }
    let(:user_row) { create(:user_row, user_list_upload: user_list_upload) }

    describe "#before_user_save_status" do
      it "returns :to_create_with_no_errors when there is no matching user" do
        expect(user_row.before_user_save_status).to eq(:to_create_with_no_errors)
      end

      it "returns :to_create_with_errors when the user is invalid" do
        allow(user_row).to receive(:user_valid?).and_return(false)
        expect(user_row.before_user_save_status).to eq(:to_create_with_errors)
      end

      context "when there is a matching user" do
        let(:user_row) { create(:user_row, user_list_upload: user_list_upload, matching_user:) }
        let(:matching_user) { create(:user) }

        context "when no changes will be made to the matching user" do
          before do
            allow(user_row).to receive(:will_change_matching_user?).and_return(false)
          end

          it "returns :up_to_date" do
            expect(user_row.before_user_save_status).to eq(:up_to_date)
          end
        end

        context "when changes will be made to the matching user" do
          before do
            allow(user_row).to receive(:will_change_matching_user?).and_return(true)
          end

          it "returns :to_update_with_no_errors when the user is valid" do
            expect(user_row.before_user_save_status).to eq(:to_update_with_no_errors)
          end

          it "returns :to_update_with_errors when the user is invalid" do
            allow(user_row).to receive(:user_valid?).and_return(false)
            expect(user_row.before_user_save_status).to eq(:to_update_with_errors)
          end
        end
      end
    end

    describe "#after_user_save_status" do
      it "returns :pending when no save attempt has been made" do
        expect(user_row.after_user_save_status).to eq(:pending)
      end

      context "when save attempt exists" do
        let!(:user_save_attempt) { create(:user_save_attempt, user_row: user_row) }

        context "when no organisation can be assigned" do
          before do
            user_save_attempt.update!(error_type: "no_organisation_to_assign")
          end

          it "returns :organisation_needs_to_be_assigned" do
            expect(user_row.reload.after_user_save_status).to eq(:organisation_needs_to_be_assigned)
          end
        end

        context "when save attempt failed" do
          before do
            user_save_attempt.update!(success: false)
          end

          it "returns :error" do
            expect(user_row.reload.after_user_save_status).to eq(:error)
          end
        end

        context "when save attempt succeeded" do
          before do
            user_save_attempt.update!(success: true)
          end

          it "returns :created for new users" do
            allow(user_row).to receive(:before_user_save_status).and_return(:to_create)
            expect(user_row.reload.after_user_save_status).to eq(:created)
          end

          it "returns :updated for existing users" do
            allow(user_row).to receive(:before_user_save_status).and_return(:to_update)
            expect(user_row.reload.after_user_save_status).to eq(:updated)
          end

          it "returns :updated for up_to_date users" do
            allow(user_row).to receive(:before_user_save_status).and_return(:up_to_date)
            expect(user_row.reload.after_user_save_status).to eq(:updated)
          end
        end
      end
    end

    describe "#before_invitation_status" do
      it "returns :already_invited when previously invited" do
        allow(user_row).to receive(:previously_invited?).and_return(true)
        expect(user_row.before_invitation_status).to eq(:already_invited)
      end

      context "when not previously invited" do
        context "when invitable" do
          before do
            allow(user_row).to receive(:invitable?).and_return(true)
          end

          it "returns :invitable" do
            expect(user_row.before_invitation_status).to eq(:invitable)
          end
        end

        context "when not invitable" do
          before do
            allow(user_row).to receive(:invitable?).and_return(false)
          end

          it "returns :not_invitable" do
            expect(user_row.before_invitation_status).to eq(:not_invitable)
          end
        end
      end
    end

    describe "#after_invitation_status" do
      it "returns :pending when no invitation attempt has been made" do
        expect(user_row.after_invitation_status).to eq(:pending)
      end

      context "when invitation attempts exist" do
        context "when all invitations failed" do
          let!(:invitation_attempt) do
            create(:invitation_attempt, user_row: user_row, success: false)
          end

          it "returns :error" do
            expect(user_row.after_invitation_status).to eq(:error)
          end
        end

        context "when at least one invitation succeeded" do
          let!(:invitation_attempt) do
            create(:invitation_attempt, user_row: user_row, success: true)
          end

          it "returns :invited" do
            expect(user_row.after_invitation_status).to eq(:invited)
          end
        end
      end
    end
  end
end
