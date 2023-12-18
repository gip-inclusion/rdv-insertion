describe Organisations::Update, type: :service do
  subject do
    described_class.call(organisation:)
  end

  let!(:rdv_solidarites_organisation_id) { 1010 }
  let!(:organisation) do
    create(:organisation, organisation_attributes.merge(
                            rdv_solidarites_organisation_id: rdv_solidarites_organisation_id
                          ))
  end
  let!(:organisation_attributes) do
    { name: "PIE Pantin", email: "pie@pantin.fr", phone_number: "0102030405" }
  end

  describe "#call" do
    before do
      allow(organisation).to receive(:save).and_return(true)
      allow(RdvSolidaritesApi::UpdateOrganisation).to receive(:call).with(
        {
          :organisation_attributes =>
            {
              :email => "pie@pantin.fr",
              :name => "PIE Pantin",
              :phone_number => "0102030405",
              "verticale" => "rdv_insertion"
            },
          :rdv_solidarites_organisation_id => 1010
        }
      ).and_return(OpenStruct.new(success?: true))
    end

    it "tries to save the organisation in db" do
      expect(organisation).to receive(:save)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the organisation has no rdv solidarites id" do
      let!(:organisation) do
        create(:organisation, organisation_attributes.merge(rdv_solidarites_organisation_id: nil))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["L'organisation n'est pas reliée à une organisation RDV-Solidarités"])
      end
    end

    context "when the organisation cannot be saved in db" do
      before do
        allow(organisation).to receive(:save)
          .and_return(false)
        allow(organisation).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return("some error")
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end
    end

    context "when the rdv solidarites organisation update fails" do
      before do
        allow(RdvSolidaritesApi::UpdateOrganisation).to receive(:call)
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end
    end
  end
end
