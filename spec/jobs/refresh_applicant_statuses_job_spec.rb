describe RefreshApplicantStatusesJob, type: :job do
  subject do
    described_class.new.perform(applicant_ids)
  end

  let!(:applicant_ids) { [23, 24] }
  let!(:applicant) { create(:applicant) }

  describe "#perform" do
    before do
      allow(Applicant).to receive(:includes)
        .and_return(Applicant)
      allow(Applicant).to receive(:where)
        .and_return([applicant])
      allow(applicant).to receive(:set_status)
      allow(applicant).to receive(:save!)
    end

    it "retrieves the applicants" do
      expect(Applicant).to receive(:where)
        .with(id: applicant_ids)
      subject
    end

    it "sets the status and saves" do
      expect(applicant).to receive(:set_status)
      expect(applicant).to receive(:save!)
      subject
    end
  end
end
