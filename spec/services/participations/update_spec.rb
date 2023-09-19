describe Participations::Update, type: :service do
  subject do
    described_class.call(
      participation: participation,
      rdv_solidarites_session: rdv_solidarites_session,
      participation_params: participation_params
    )
  end

  let(:participation) { create(:participation, status: "unknown") }
  let(:participation_params) { { status: "seen" } }
  let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  let(:stub_rdvs) do
    allow(RdvSolidaritesApi::UpdateParticipation).to receive(:call).once.with(
      {
        :participation_attributes => { :status => "seen" },
        :rdv_solidarites_session => rdv_solidarites_session,
        :rdv_solidarites_rdvs_user_id => participation.rdv_solidarites_participation_id
      }
    )
  end

  describe "#call" do
    context "RDVs update succeeds" do
      before { stub_rdvs.and_return(OpenStruct.new(success?: true)) }

      it "changes participation status" do
        subject
        expect(participation.reload.status).to eq("seen")
      end
    end

    context "RDVs update fails" do
      before { stub_rdvs.and_return(OpenStruct.new(success?: false)) }

      it "doesn't update participation status" do
        subject
        expect(participation.reload.status).to eq("unknown")
      end
    end
  end
end
