describe DeleteApplicantJob, type: :job do
  subject do
    described_class.new.perform(rdv_solidarites_user_id)
  end

  let!(:rdv_solidarites_user_id) { { id: 1 } }
  let!(:applicant) { create(:applicant) }

  describe "#perform" do
    before do
      allow(Applicant).to receive(:find_by)
        .with(rdv_solidarites_user_id: rdv_solidarites_user_id)
        .and_return(applicant)
      allow(applicant).to receive(:destroy!)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    it "finds the matching applicant" do
      expect(Applicant).to receive(:find_by)
        .with(rdv_solidarites_user_id: rdv_solidarites_user_id)
      subject
    end

    it "destroys the applicant" do
      expect(applicant).to receive(:destroy!)
      subject
    end
  end
end
