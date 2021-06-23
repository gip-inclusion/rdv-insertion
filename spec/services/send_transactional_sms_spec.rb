describe SendTransactionalSms, type: :service do
  let(:phone_number) { "+33648498119" }
  let(:content) { "Bienvenue sur RDV-Solidarités" }
  let(:sib_api_mock) { instance_double(SibApiV3Sdk::TransactionalSMSApi) }
  let(:send_transac_mock) { instance_double(SibApiV3Sdk::SendTransacSms) }

  describe "#call" do
    context "in production" do
      before do
        allow(ENV).to receive(:[]).with("SENDINBLUE_API_V3_KEY").and_return("send_in_blue_secret")
        allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sib_api_mock)
        allow(SibApiV3Sdk::SendTransacSms).to receive(:new)
          .with(
            sender: "Rdv RSA",
            recipient: "+33648498119",
            content: "Bienvenue sur RDV-Solidarités",
            type: "transactional"
          )
          .and_return(send_transac_mock)
      end

      it "calls SIB API" do
        expect(sib_api_mock).to receive(:send_transac_sms).with(send_transac_mock)

        described_class.new(phone_number: phone_number, content: content).call
      end
    end
  end
end
