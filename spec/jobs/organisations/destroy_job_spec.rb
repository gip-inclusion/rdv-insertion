describe Organisations::DestroyJob do
  subject do
    described_class.new.perform(organisation_id)
  end

  let(:organisation) { create(:organisation) }

  describe "#perform" do
    context "when organisation exists" do
      let(:organisation_id) { organisation.id }

      it "destroys the organisation" do
        subject
        expect(Organisation.find_by(id: organisation_id)).to be_nil
      end
    end
  end
end
