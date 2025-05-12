describe Sms::SendWithPrimotexto, type: :service do
  subject do
    described_class.call(
      phone_number: phone_number, sender_name: sender_name, content: content
    )
  end

  let(:phone_number) { "+33648498119" }
  let(:sender_name) { "Dept26" }
  let(:content) { "Vous êtes invités à prendre rendez-vous le 12/05/2025 à 10h00" }

  before do
    allow(PrimotextoClient).to receive(:send_sms).and_return(OpenStruct.new(success?: true))
  end

  it "is a success" do
    is_a_success
  end

  it "calls the PrimotextoClient" do
    subject
    expect(PrimotextoClient).to have_received(:send_sms).with(phone_number:, content:, sender_name:)
  end

  context "when the PrimotextoClient returns a failure" do
    before do
      allow(PrimotextoClient).to receive(:send_sms).and_return(OpenStruct.new(success?: false, body: { "code" => "some code" }))
    end

    it "is a failure" do
      is_a_failure
    end

    it "returns the error" do
      expect(subject.errors).to eq(["une erreur est survenue en envoyant le sms via Primotexto: {\"code\" => \"some code\"}"])
    end
  end
end