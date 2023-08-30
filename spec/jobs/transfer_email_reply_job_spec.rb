describe TransferEmailReplyJob do
  subject do
    described_class.new.perform(brevo_payload)
  end

  before do
    allow(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
    allow(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
    allow(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
    allow(MattermostClient).to receive(:send_to_notif_channel)
  end

  let!(:organisation) { create(:organisation, email: "organisation@departement.fr") }
  let!(:applicant) do
    create(:applicant, email: "bene_ficiaire@gmail.com",
                       first_name: "Bénédicte", last_name: "Ficiaire", organisations: [organisation])
  end
  let(:rdv_uuid) { "8fae4d5f-4d63-4f60-b343-854d939881a3" }
  let!(:rdv_context) { create(:rdv_context, applicant: applicant) }
  let!(:participation) { create(:participation, convocable: true, rdv_context: rdv_context, applicant: applicant) }
  let!(:rdv) do
    create(:rdv, uuid: rdv_uuid, organisation: organisation, participations: [participation])
  end
  let!(:invitation) do
    create(:invitation, applicant: applicant, organisations: [organisation])
  end

  let!(:brevo_valid_payload) do
    # The usual payload has more info, non-essential fields are removed for readability.
    {
      Subject: "coucou",
      Attachments: [],
      Headers: {
        Subject: "coucou",
        From: "Bénédicte Ficiaire <bene_ficiaire@gmail.com>",
        To: "rdv+8fae4d5f-4d63-4f60-b343-854d939881a3@reply.rdv-insertion.fr",
        Date: "Sun, 25 Jun 2023 12:22:15 +0200"
      },
      ExtractedMarkdownMessage: "Je souhaite annuler mon RDV",
      ExtractedMarkdownSignature: nil
    }
  end
  let!(:brevo_payload) { brevo_valid_payload } # use valid payload by default

  context "when all goes well for a reply to a notification" do
    it "calls the ReplyTransferMailer with the right method" do
      expect(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
      subject
    end
  end

  context "when all goes well for a reply to an invitation" do
    let!(:brevo_payload) do
      brevo_valid_payload.tap { |hash| hash[:Headers][:To] = "invitation+#{invitation.uuid}@reply.rdv-insertion.fr" }
    end

    it "calls the ReplyTransferMailer with the right method" do
      expect(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
      subject
    end
  end

  context "when reply token does not match any in DB" do
    let(:rdv_uuid) { "6df62597-632e-4be1-a273-708ab58e4765" }

    it "calls the ReplyTransferMailer with the default method" do
      expect(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
      subject
    end
  end

  context "when an e-mail address does not match our patterns" do
    let(:brevo_payload) do
      brevo_valid_payload.tap { |hash| hash[:Headers][:To] = "quelquechose@reply.rdv-insertion.fr" }
    end

    it "calls the ReplyTransferMailer with the default method" do
      expect(ReplyTransferMailer).to receive_message_chain(:with, :send, :deliver_now)
      subject
    end
  end

  it "sends a notif on mattermost" do
    expect(MattermostClient).to receive(:send_to_notif_channel)
      .with("📩 Un email d'un usager vient d'être transféré")
    subject
  end
end
