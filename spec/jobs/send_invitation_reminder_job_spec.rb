describe SendInvitationReminderJob, type: :job do
  subject do
    described_class.new.perform(applicant_id, invitation_format)
  end

  let!(:applicant_id) { 3333 }
  let!(:invitation_format) { "sms" }
  let!(:applicant) do
    create(:applicant, id: applicant_id, department: department)
  end
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:first_invitation) do
    create(
      :invitation,
      valid_until: Time.zone.parse("2022-05-15 15:05"), sent_at: Time.zone.parse("2022-05-01 14:01"),
      applicant: applicant, organisations: [organisation], rdv_context: rdv_context, token: "123",
      link: "www.rdv-insertion.fr/invitations/redirect?token=123",
      number_of_days_to_accept_invitation: 3, help_phone_number: "0101010101",
      rdv_solidarites_lieu_id: nil, department: department
    )
  end
  let!(:rdv_context) { create(:rdv_context, applicant: applicant, status: "invitation_pending") }
  let!(:invitation) { build(:invitation) }

  before do
    travel_to(Time.zone.parse("2022-05-04 11:00"))
    allow(Invitation).to receive(:new).and_return(invitation)
    allow(Invitations::SaveAndSend).to receive(:call)
      .with(invitation: invitation)
      .and_return(OpenStruct.new(success?: true))
    allow(MattermostClient).to receive(:send_to_notif_channel)
  end

  it "instanciates an invitation with attributes from the first one" do
    expect(Invitation).to receive(:new)
      .with(
        reminder: true,
        applicant: applicant,
        department: department,
        organisations: [organisation],
        rdv_context: rdv_context,
        format: invitation_format,
        number_of_days_to_accept_invitation: 3,
        help_phone_number: "0101010101",
        rdv_solidarites_lieu_id: nil,
        link: "www.rdv-insertion.fr/invitations/redirect?token=123",
        token: "123",
        valid_until: Time.zone.parse("2022-05-15 15:05")
      )
    subject
  end

  it "saves and send the invitation" do
    expect(Invitations::SaveAndSend).to receive(:call)
    subject
  end

  context "when the first invitation was not sent 3 days ago" do
    before { first_invitation.update! sent_at: Time.zone.parse("2022-05-02 14:01") }

    it "does not instanciate an invitation" do
      expect(Invitation).not_to receive(:new)
      subject
    end

    it "does not save and send the invitation" do
      expect(Invitations::SaveAndSend).not_to receive(:call)
      subject
    end

    it "sends a notification to mattermost" do
      expect(MattermostClient).to receive(:send_to_notif_channel)
        .with("🚫 L'allocataire 3333 n'est pas éligible à la relance.")
      subject
    end
  end

  context "when the first invitation expires in less than 2 days" do
    before { first_invitation.update! valid_until: Time.zone.parse("2022-05-05 14:01") }

    it "does not instanciate an invitation" do
      expect(Invitation).not_to receive(:new)
      subject
    end

    it "does not save and send the invitation" do
      expect(Invitations::SaveAndSend).not_to receive(:call)
      subject
    end

    it "sends a notification to mattermost" do
      expect(MattermostClient).to receive(:send_to_notif_channel)
        .with("🚫 L'allocataire 3333 n'est pas éligible à la relance.")
      subject
    end
  end

  context "when the rdv context status is not invitation_pending" do
    let!(:rdv_context) { create(:rdv_context, applicant: applicant, status: "rdv_pending") }

    it "does not instanciate an invitation" do
      expect(Invitation).not_to receive(:new)
      subject
    end

    it "does not save and send the invitation" do
      expect(Invitations::SaveAndSend).not_to receive(:call)
      subject
    end

    it "sends a notification to mattermost" do
      expect(MattermostClient).to receive(:send_to_notif_channel)
        .with("🚫 L'allocataire 3333 n'est pas éligible à la relance.")
      subject
    end
  end

  context "when an invitation has already been sent in the last 24hrs in the same format" do
    let!(:invitation) { create(:invitation, sent_at: Time.zone.parse("2022-05-04 08:00"), applicant: applicant) }

    it "does not instanciate an invitation" do
      expect(Invitation).not_to receive(:new)
      subject
    end

    it "does not save and send the invitation" do
      expect(Invitations::SaveAndSend).not_to receive(:call)
      subject
    end
  end

  context "when the save and send service fails" do
    before do
      allow(Invitations::SaveAndSend).to receive(:call)
        .and_return(OpenStruct.new(success?: false, errors: ["cannot send invitation"]))
    end

    it "raises an error" do
      expect { subject }.to raise_error(SendInvitationReminderJobError, "cannot send invitation")
    end
  end
end
