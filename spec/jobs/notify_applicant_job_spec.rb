describe NotifyApplicantJob, type: :job do
  subject do
    described_class.new.perform(applicant_id, rdv_attributes, event)
  end

  let!(:applicant_id) { 23 }
  let!(:rdv_attributes) { { id: 12, lieu: lieu, motif: motif, starts_at: starts_at } }
  let!(:lieu) { { name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif) { { location_type: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:applicant) { create(:applicant, id: applicant_id) }
  let!(:event) { "created" }
  let!(:rdv_solidarites_rdv) { OpenStruct.new(id: 12) }

  describe "#perform" do
    before do
      allow(RdvSolidarites::Rdv).to receive(:new)
        .with(rdv_attributes)
        .and_return(rdv_solidarites_rdv)
      allow(Notification).to receive(:where).and_return([])
      allow(Applicant).to receive_message_chain(:includes, :find).and_return(applicant)
      [Notifications::RdvCreated, Notifications::RdvUpdated, Notifications::RdvCancelled].each do |klass|
        allow(klass).to receive(:call)
          .and_return(OpenStruct.new(success?: true))
      end
    end

    it "calls the appropriate service" do
      expect(Notifications::RdvCreated).to receive(:call)
        .with(applicant: applicant, rdv_solidarites_rdv: rdv_solidarites_rdv)
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

    context "when the applicant is already notified" do
      let!(:notification) { create(:notification) }

      before do
        allow(Notification).to receive(:where)
          .with(rdv_solidarites_rdv_id: 12, event: "rdv_created")
          .and_return(notification)
        allow(MattermostClient).to receive(:send_to_notif_channel)
      end

      it "does not call any service" do
        [Notifications::RdvCreated, Notifications::RdvUpdated, Notifications::RdvCancelled].each do |klass|
          expect(klass).not_to receive(:call)
        end
        subject
      end

      it "sends a message to mattermost" do
        expect(MattermostClient).to receive(:send_to_notif_channel)
        subject
      end
    end
  end
end
