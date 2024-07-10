require Rails.root.join("lib/organisations/destroy_multiple")

describe Organisations::DestroyMultiple do
  subject do
    described_class.call(organisation_ids:)
  end

  let(:agent) { create(:agent) }
  let(:organisation) { create(:organisation, agents: [agent]) }
  let(:organisation_ids) { [organisation.id] }

  describe "#call" do
    it "calls the DestroyJob for each organisation" do
      expect(Organisations::DestroyJob).to receive(:perform_async).with(organisation.id)
      stub_request(
        :get,
        "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/organisations/#{organisation.rdv_solidarites_organisation_id}"
      ).to_return(status: 200, body: { organisation: { name: organisation.name } }.to_json)
      allow($stdin).to receive(:gets).and_return("y")
      subject
    end

    context "when an organisation is not found" do
      let(:organisation_ids) { [999] }

      it "logs an error" do
        expect { subject }.to output(/Organisation with id 999 not found/).to_stdout
      end
    end
  end
end
