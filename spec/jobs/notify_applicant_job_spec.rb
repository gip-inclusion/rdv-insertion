describe NotifyApplicantJob, type: :job do
  subject do
    described_class.new.perform(applicant_id, lieu, motif, starts_at, event)
  end

  let!(:applicant_id) { 23 }
  let!(:lieu) { { name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif) { { location_type: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:applicant) { create(:applicant, id: applicant_id) }
  let!(:event) { "created" }

  describe "#call" do
    before do
      [Notifications::RdvCreated, Notifications::RdvUpdated, Notifications::RdvCancelled].each do |klass|
        allow(klass).to receive(:call)
          .and_return(OpenStruct.new(success?: true))
      end
    end

    it "calls the appropriate service" do
      expect(Notifications::RdvCreated).to receive(:call)
        .with(applicant: applicant, lieu: lieu, motif: motif, starts_at: starts_at)
      subject
    end

    context "when the service fails" do
      before do
        [Notifications::RdvCreated, Notifications::RdvUpdated, Notifications::RdvCancelled].each do |klass|
          allow(klass).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
        end
      end

      it "raises an error" do
        expect { subject }.to raise_error(NotificationsJobError, "something happened")
      end
    end
  end
end
