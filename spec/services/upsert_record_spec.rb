describe UpsertRecord, type: :service do
  subject do
    described_class.call(
      klass: klass, rdv_solidarites_attributes: rdv_solidarites_attributes,
      additional_attributes: additional_attributes
    )
  end

  let!(:klass) { Rdv }
  let!(:additional_attributes) do
    {
      participations_attributes: [
        {
          id: nil,
          status: 'unknown',
          applicant_id: applicant_id,
          rdv_solidarites_participation_id: 998
        }
      ]
    }
  end
  let!(:applicant_id) { 33 }
  let!(:applicant_ids) { [applicant_id] }
  let!(:rdv_solidarites_rdv_id) { 12 }
  let!(:rdv_solidarites_attributes) do
    { id: 12, lieu: lieu, motif: motif, starts_at: starts_at, duration_in_min: duration_in_min,
      status: status }
  end
  let!(:applicant) { create(:applicant, id: 33) }
  let!(:lieu) { { name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif) { { location_type: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:duration_in_min) { 45 }
  let!(:status) { "unknown" }
  let!(:rdv) { create(:rdv, participations: [participation], id: 55) }
  let!(:participation) { create(:participation, applicant: applicant) }

  describe "#call" do
    before do
      allow(Rdv).to receive(:find_or_initialize_by)
        .with(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
        .and_return(rdv)
      allow(rdv).to receive(:save!)
      allow(rdv).to receive(:changed?).and_return(true)
    end

    it "retrieves the rdv if present" do
      expect(Rdv).to receive(:find_or_initialize_by)
        .with(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
      subject
    end

    it "updates the attributes" do
      rdv.reload
      subject
      expect(rdv.starts_at).to eq(starts_at)
      expect(rdv.duration_in_min).to eq(duration_in_min)
      expect(rdv.status).to eq(status)
      expect(rdv.applicant_ids).to eq(applicant_ids)
      expect(rdv.id).not_to eq(rdv_solidarites_rdv_id)
    end

    it "saves the record" do
      expect(rdv).to receive(:assign_attributes)
      expect(rdv).to receive(:save!)
      subject
    end

    context "when it is an old update" do
      let!(:additional_attributes) { { last_webhook_update_received_at: "2021-09-08 11:05:00 UTC" } }
      let!(:rdv) do
        create(:rdv, last_webhook_update_received_at: "2021-09-08 11:06:00 UTC")
      end

      it "does not update the rdv" do
        expect(rdv).not_to receive(:assign_attributes)
        expect(rdv).not_to receive(:save!)
        subject
      end
    end
  end
end
