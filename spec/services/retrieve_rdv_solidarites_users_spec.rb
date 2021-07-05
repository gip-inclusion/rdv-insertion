describe RetrieveRdvSolidaritesUsers, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      ids: ids, organisation_id: organisation_id, page: page
    )
  end

  let(:organisation_id) { 23 }
  let(:ids) { [25] }
  let(:page) { 1 }
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

    before do
      allow(RdvSolidaritesClient).to receive(:new)
        .with(rdv_solidarites_session)
        .and_return(rdv_solidarites_client)
    end

    context "when no ids is passed" do
      let(:ids) { [] }

      it "is a success" do
        is_a_success
      end

      it "does not store any users" do
        expect(subject.rdv_solidarites_users).to eq([])
      end
    end

    context "when rdv solidarites response is successful" do
      let(:response_body) do
        { users: [{ id: 25, first_name: "John", last_name: "Doe", email: "johndoe@example.com" }] }.to_json
      end
      let(:rdv_solidarites_user) { instance_double(RdvSolidaritesUser) }
      let(:parsed_response) { JSON.parse(response_body) }

      before do
        allow(rdv_solidarites_client).to receive(:get_users)
          .and_return(OpenStruct.new(success?: true, body: response_body))
        allow(RdvSolidaritesUser).to receive(:new)
          .and_return(rdv_solidarites_user)
      end

      it "is a success" do
        is_a_success
      end

      it "calls the get users method" do
        expect(rdv_solidarites_client).to receive(:get_users)
          .with(organisation_id, page, ids)
        subject
      end

      it "stores the rdv solidarites user" do
        expect(RdvSolidaritesUser).to receive(:new)
          .with(parsed_response['users'].first)
        subject
        expect(subject.rdv_solidarites_users).to eq([rdv_solidarites_user])
      end
    end
  end
end
