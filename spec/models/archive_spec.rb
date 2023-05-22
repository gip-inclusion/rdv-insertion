describe Archive do
  subject { build(:archive, department: department, applicant: applicant) }

  let!(:department) { create(:department) }
  let!(:applicant) { create(:applicant) }

  describe "no collision" do
    context "when the applicant is not archived" do
      let(:archive) { build(:archive, department: department, applicant: applicant) }

      it { expect(subject).to be_valid }
    end

    context "when the applicant is archived in another department" do
      let!(:existing_archive) do
        create(:archive, applicant: applicant, department: create(:department))
      end

      it { expect(subject).to be_valid }
    end

    context "when the applicant is already archived in the department" do
      let!(:existing_archive) do
        create(:archive, applicant: applicant, department: department)
      end

      it { expect(subject).not_to be_valid }
    end
  end

  describe "invitation invalidations" do
    let!(:invitation_inside_department) do
      create(:invitation, applicant: applicant, department: department)
    end

    let!(:invitation_outside_department) do
      create(:invitation, applicant: applicant, department: create(:department))
    end

    it "invalidates the applicant department invitations" do
      expect(InvalidateInvitationJob).to receive(:perform_async)
        .with(invitation_inside_department.id)
      expect(InvalidateInvitationJob).not_to receive(:perform_async)
        .with(invitation_outside_department.id)
      subject.save
    end
  end
end
