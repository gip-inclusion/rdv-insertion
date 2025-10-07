describe UserListUpload::SaveUser, type: :service do
  subject { described_class.call(user_row:) }

  let(:user) { create(:user) }
  let(:organisation) { create(:organisation) }
  let(:referents) { [create(:agent)] }
  let(:tags) { [create(:tag)] }
  let(:motif_category) { create(:motif_category) }

  let(:user_row) do
    instance_double(
      "UserRow",
      user: user,
      referents: referents,
      tags: tags,
      motif_category_to_assign: motif_category,
      organisation_to_assign: organisation_to_assign
    )
  end

  let(:organisation_to_assign) { nil }

  describe "#call" do
    before do
      allow(Users::Save).to receive(:call).and_return(OpenStruct.new(success?: true, user: user))
      allow(UserListUpload::RetrieveOrganisationToAssign)
        .to receive(:call)
        .and_return(OpenStruct.new(success?: true, organisation:))
    end

    it("is a success") { is_a_success }

    it "assigns resources to the user" do
      expect(user).to receive(:assign_motif_category).with(motif_category.id)
      subject

      expect(user.referents).to eq(referents)
      expect(user.tags).to eq(tags)
    end

    context "when organisation is provided in user_row" do
      let(:organisation_to_assign) { organisation }

      it "saves the user with the provided organisation" do
        expect(Users::Save).to receive(:call)
          .with(user: user, organisation: organisation)

        subject
      end

      it "does not retrieve the organisatio to assign" do
        expect(UserListUpload::RetrieveOrganisationToAssign).not_to receive(:call)
        subject
      end
    end

    context "when organisation needs to be retrieved" do
      before do
        allow(UserListUpload::RetrieveOrganisationToAssign).to receive(:call)
          .with(user_row: user_row)
          .and_return(OpenStruct.new(success?: true, organisation: organisation))
      end

      it("is a success") { is_a_success }

      it "saves the user with the retrieved organisation" do
        expect(Users::Save).to receive(:call)
          .with(user: user, organisation: organisation)

        subject
      end

      context "when organisation retrieval fails" do
        before do
          allow(UserListUpload::RetrieveOrganisationToAssign).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["Some error"]))
        end

        it("is a failure") { is_a_failure }

        it "sets the correct error type" do
          expect(subject.error_type).to eq(:no_organisation_to_assign)
        end

        it "includes the retrieval service errors" do
          expect(subject.errors).to eq(["Some error"])
        end
      end
    end

    context "when user is archived" do
      let!(:organisation) { create(:organisation, users: [user]) }
      let!(:archive) { create(:archive, user: user, organisation: organisation) }

      it "unarchives the user" do
        expect { subject }.to change { user.archives.count }.from(1).to(0)
      end
    end

    context "when the follow up is closed" do
      let!(:follow_up) { create(:follow_up, user: user, motif_category: motif_category, closed_at: Time.current) }

      it "reopens the follow up" do
        expect { subject }.to change { follow_up.reload.closed_at }.to(nil)
      end
    end

    context "when no motif category is assigned" do
      let(:user_row) do
        instance_double(
          "UserRow",
          user: user,
          referents: referents,
          tags: tags,
          motif_category_to_assign: nil,
          organisation_to_assign: organisation_to_assign
        )
      end

      it "does not create a follow up" do
        expect { subject }.not_to change(FollowUp, :count)
      end

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end

    context "when user save fails" do
      before do
        allow(Users::Save).to receive(:call).and_return(OpenStruct.new(success?: false, errors: ["Some error"]))
      end

      it("is a failure") { is_a_failure }

      it "includes the save service errors" do
        expect(subject.errors).to eq(["Some error"])
      end
    end
  end
end
