describe Archive do
  subject { build(:archive, department: department, user: user) }

  let!(:department) { create(:department) }
  let!(:user) { create(:user) }

  describe "no collision" do
    context "when the user is not archived" do
      let(:archive) { build(:archive, department: department, user: user) }

      it { expect(subject).to be_valid }
    end

    context "when the user is archived in another department" do
      let!(:existing_archive) do
        create(:archive, user: user, department: create(:department))
      end

      it { expect(subject).to be_valid }
    end

    context "when the user is already archived in the department" do
      let!(:existing_archive) do
        create(:archive, user: user, department: department)
      end

      it { expect(subject).not_to be_valid }
    end
  end

  describe "invitation invalidations" do
    let!(:invitation_inside_department) do
      create(:invitation, user: user, department: department)
    end

    let!(:invitation_outside_department) do
      create(:invitation, user: user, department: create(:department))
    end

    it "invalidates the user department invitations" do
      expect(InvalidateInvitationJob).to receive(:perform_async)
        .with(invitation_inside_department.id)
      expect(InvalidateInvitationJob).not_to receive(:perform_async)
        .with(invitation_outside_department.id)
      subject.save
    end
  end
end
