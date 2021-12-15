describe RdvSolidaritesApi::RetrieveOrganisationResources, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
      resource_name: resource_name,
      additional_args: additional_args
    )
  end

  let!(:rdv_solidarites_organisation_id) { 23 }
  let!(:additional_args) { user_ids }
  let!(:user_ids) { [25] }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let!(:resource_name) { "user" }

  describe "#call" do
    let!(:response_body) do
      { users: [{ id: 25, first_name: "John", last_name: "Doe", email: "johndoe@example.com" }], meta: {} }.to_json
    end
    let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }
    let!(:parsed_response) { JSON.parse(response_body) }
    let!(:page) { 1 }

    before do
      allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_users)
      allow(rdv_solidarites_client).to receive(:get_users)
        .and_return(OpenStruct.new(success?: true, body: response_body))
      allow(RdvSolidarites::User).to receive(:new)
        .and_return(rdv_solidarites_user)
    end

    it "retrieves the resources" do
      expect(rdv_solidarites_client).to receive(:get_users)
        .with(rdv_solidarites_organisation_id, page, user_ids)
      subject
    end

    it "stores the resources" do
      expect(subject.users).to eq([rdv_solidarites_user])
    end

    it("is a success") { is_a_success }

    context "without additional_args" do
      let!(:additional_args) { nil }

      it "retrieves the resources without the additional argument" do
        expect(rdv_solidarites_client).to receive(:get_users)
          .with(rdv_solidarites_organisation_id, page)
        subject
      end
    end

    context "when response is unsuccessful" do
      before do
        allow(rdv_solidarites_client).to receive(:get_users)
          .and_return(OpenStruct.new(success?: false, body: { error_messages: ['some error'] }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "stores the error message" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
