describe Archive do
  subject { build(:archive, organisation: organisation, user: user) }

  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user) }

  describe "no collision" do
    context "when the user is not archived" do
      let(:archive) { build(:archive, organisation: organisation, user: user) }

      it { expect(subject).to be_valid }
    end

    context "when the user is archived in another organisation" do
      let!(:existing_archive) do
        create(:archive, user: user, organisation: create(:organisation))
      end

      it { expect(subject).to be_valid }
    end

    context "when the user is already archived in the organisation" do
      let!(:existing_archive) do
        create(:archive, user: user, organisation: organisation)
      end

      it { expect(subject).not_to be_valid }
    end
  end

  describe "invitation invalidations" do
    let!(:other_organisation) { create(:organisation) }
    let!(:invitation_for_organisation) do
      create(:invitation, user: user, department: organisation.department, organisations: [organisation])
    end

    let!(:invitation_for_other_organisation) do
      create(:invitation, user: user, department: other_organisation.department, organisations: [other_organisation])
    end

    it "invalidates the user organisation invitations" do
      expect(InvalidateInvitationJob).to receive(:perform_async)
        .with(invitation_for_organisation.id)
      expect(InvalidateInvitationJob).not_to receive(:perform_async)
        .with(invitation_for_other_organisation.id)
      subject.save
    end
  end
end
