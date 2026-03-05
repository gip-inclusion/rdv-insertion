describe Rdvs::UpdateStatus, type: :service do
  subject do
    described_class.call(participation: participation, status: status)
  end

  let(:participation) { create(:participation, status: "unknown") }
  let(:status) { "seen" }

  let(:stub_rdvs) do
    allow(RdvSolidaritesApi::UpdateRdvStatus).to receive(:call).once.with(
      rdv_solidarites_rdv_id: participation.rdv_solidarites_rdv_id,
      status: "seen"
    )
  end

  describe "#call" do
    context "when the RDVs update succeeds" do
      before { stub_rdvs.and_return(OpenStruct.new(success?: true)) }

      it "changes participation status" do
        subject
        expect(participation.reload.status).to eq("seen")
      end
    end

    context "when the RDVs update fails" do
      before { stub_rdvs.and_return(OpenStruct.new(success?: false)) }

      it "doesn't update participation status" do
        subject
        expect(participation.reload.status).to eq("unknown")
      end
    end
  end
end
