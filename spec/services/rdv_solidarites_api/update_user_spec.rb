describe RdvSolidaritesApi::UpdateUser, type: :service do
  subject do
    described_class.call(user_attributes: user_attributes,
                         rdv_solidarites_session: rdv_solidarites_session,
                         rdv_solidarites_user_id: rdv_solidarites_user_id)
  end

  let(:user_attributes) do
    { first_name: "john", last_name: "doe", address: "16 rue de la tour", email: "johndoe@example.com" }
  end
  let(:rdv_solidarites_user_id) { 1 }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    let(:response_body) do
      { user: user_attributes.merge(id: 1) }.to_json
    end

    let(:parsed_response) { JSON.parse(response_body) }

    before do
      allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_session).to receive(:valid?).and_return(true)
      allow(rdv_solidarites_client).to receive(:update_user)
        .with(rdv_solidarites_user_id, user_attributes)
        .and_return(OpenStruct.new(body: response_body))
    end

    it "tries to update a user in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:update_user)
        .with(rdv_solidarites_user_id, user_attributes)
      subject
    end

    context "when the response is successful" do
      let(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }

      before do
        allow(rdv_solidarites_client).to receive(:update_user)
          .with(rdv_solidarites_user_id, user_attributes)
          .and_return(OpenStruct.new(body: response_body, success?: true))
        allow(RdvSolidarites::User).to receive(:new)
          .with(parsed_response["user"])
          .and_return(rdv_solidarites_user)
      end

      it "is a success" do
        is_a_success
      end

      it "stores the rdv solidarites user" do
        expect(subject.user).to eq(rdv_solidarites_user)
      end
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:update_user)
          .with(rdv_solidarites_user_id, user_attributes)
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
