describe InviteUserJob do
  subject do
    described_class.new.perform(
      user_id, organisation_id, invitation_attributes, motif_category_attributes, rdv_solidarites_session_credentials
    )
  end

  let!(:user_id) { 9999 }
  let!(:organisation_id) { 999 }
  let!(:department) { create(:department) }
  let!(:user) { create(:user, id: user_id) }
  let!(:organisation) do
    create(:organisation, id: organisation_id, department: department)
  end
  let!(:agent) { create(:agent, email: "janedoe@gouv.fr") }
  let!(:rdv_solidarites_session_credentials) do
    { "client" => "someclient", "uid" => agent.email.to_s, "access_token" => "sometoken" }.symbolize_keys
  end
  let!(:invitation_format) { "sms" }
  let!(:invitation_attributes) do
    {
      format: "sms",
      help_phone_number: "01010101",
      rdv_solidarites_lieu_id: 444
    }
  end
  let!(:motif_category_attributes) { { short_name: "rsa_accompagnement" } }

  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  describe "#perform" do
    before do
      allow(RdvSolidaritesSessionFactory).to receive(:create_with)
        .with(rdv_solidarites_session_credentials).and_return(rdv_solidarites_session)
      allow(InviteUser).to receive(:call)
        .with(
          user:, organisations: [organisation], invitation_attributes:, motif_category_attributes:,
          rdv_solidarites_session:, check_creneaux_availability: false
        )
        .and_return(OpenStruct.new(success?: true))
    end

  it "sets the current agent" do
    subject
    expect(Current.agent).to eq(agent)
  end

    it "invites the user" do
      expect(InviteUser).to receive(:call)
        .with(
          user:, organisations: [organisation], invitation_attributes:, motif_category_attributes:,
          rdv_solidarites_session:, check_creneaux_availability: false
        )
      subject
    end

    context "when it fails to send it" do
      before do
        allow(InviteUser).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["Could not send invite"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(
          FailedServiceError,
          "Could not send invitation to user 9999 in InviteUserJob: [\"Could not send invite\"]"
        )
      end
    end
  end
end
