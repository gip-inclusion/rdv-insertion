describe CreneauOpeningRequests::SendEmailJob do
  subject { described_class.new.perform(creneau_opening_request.id) }

  let!(:creneau_opening_request) { create(:creneau_opening_request) }

  before do
    allow(CreneauOpeningRequestMailer).to receive(:request_more_creneaux)
      .with(creneau_opening_request: creneau_opening_request)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))
  end

  it "sends the email" do
    expect(CreneauOpeningRequestMailer).to receive(:request_more_creneaux)
      .with(creneau_opening_request: creneau_opening_request)

    subject
  end

  it "stamps email_sent_at on the record" do
    expect { subject }
      .to change { creneau_opening_request.reload.email_sent_at }.from(nil)
  end

  context "when email_sent_at is already present" do
    before { creneau_opening_request.update!(email_sent_at: 1.hour.ago) }

    it "does not send the email again" do
      expect(CreneauOpeningRequestMailer).not_to receive(:request_more_creneaux)

      subject
    end

    it "does not change email_sent_at" do
      expect { subject }
        .not_to(change { creneau_opening_request.reload.email_sent_at })
    end
  end
end
