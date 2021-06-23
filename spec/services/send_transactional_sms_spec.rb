describe SendTransactionalSms, type: :service do
  subject { described_class.call(phone_number: phone_number, content: content) }

  let(:phone_number) { "+33648498119" }
  let(:content) { "Bienvenue sur RDV-Solidarités" }
  let(:sib_api_mock) { instance_double(SibApiV3Sdk::TransactionalSMSApi) }

  describe "#call" do
    context "in production" do
      before do
        allow(ENV).to receive(:[]).with("SENDINBLUE_API_V3_KEY").and_return("send_in_blue_secret")
        allow(SibApiV3Sdk::TransactionalSMSApi).to receive(:new).and_return(sib_api_mock)
      end

      it "calls SIB API" do
        expect(sib_api_mock).to receive(:send_transac_sms)

        described_class.new(phone_number: phone_number, content: content).call
      end
    end
  end
end
