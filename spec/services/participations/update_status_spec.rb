describe Participations::UpdateStatus, type: :service do
  subject do
    described_class.call(participation: participation, status: status)
  end

  let(:participation) { create(:participation, status: "unknown") }
  let(:status) { "seen" }

  context "when the RDV is individual" do
    let(:stub_rdvs) do
      allow(RdvSolidaritesApi::UpdateRdvStatus).to receive(:call).once.with(
        rdv_solidarites_rdv_id: participation.rdv_solidarites_rdv_id,
        status: "seen"
      )
    end

    before { allow(participation).to receive(:collectif?).and_return(false) }

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

  context "when the RDV is collectif" do
    let(:stub_rdvs) do
      allow(RdvSolidaritesApi::UpdateParticipation).to receive(:call).once.with(
        rdv_solidarites_participation_id: participation.rdv_solidarites_participation_id,
        participation_attributes: { status: "seen" }
      )
    end

    before { allow(participation).to receive(:collectif?).and_return(true) }

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
