describe RdvSolidaritesApi::CreateUserProfile, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      user_id: user_id, organisation_id: organisation_id
    )
  end

  let!(:user_id) { 33 }
  let!(:organisation_id) { 44 }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    let(:response_body) do
      { user_profile: { user_id: user_id, organisation_id: organisation_id } }.to_json
    end
    let(:parsed_response) { JSON.parse(response_body) }

    before do
      allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:create_user_profile)
        .with(user_id, organisation_id)
        .and_return(OpenStruct.new(success?: true, body: response_body))
    end

    it "tries to create a user profile in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:create_user_profile)
        .with(user_id, organisation_id)
      subject
    end

    it "is a success" do
      is_a_success
    end

    it "stores the user profile" do
      expect(subject.user_profile).to eq(parsed_response["user_profile"])
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ['some error'] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_user_profile)
          .with(user_id, organisation_id)
          .and_return(OpenStruct.new(body: response_body, success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
