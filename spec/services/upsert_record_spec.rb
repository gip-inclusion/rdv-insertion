describe UpsertRecord, type: :service do
  subject do
    described_class.call(
      klass: klass, rdv_solidarites_object: rdv_solidarites_object,
      additional_attributes: additional_attributes
    )
  end

  let!(:klass) { Rdv }
  let!(:additional_attributes) { { applicant_ids: applicant_ids } }
  let!(:applicant_ids) { [33] }
  let!(:rdv_solidarites_rdv_id) { 12 }
  let!(:rdv_solidarites_object) { RdvSolidarites::Rdv.new(rdv_attributes) }
  let!(:rdv_attributes) do
    { id: 12, lieu: lieu, motif: motif, starts_at: starts_at, duration_in_min: duration_in_min,
      status: status }
  end
  let!(:applicant) { create(:applicant, id: 33) }
  let!(:lieu) { { name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif) { { location_type: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:duration_in_min) { 45 }
  let!(:status) { "unknown" }
  let!(:rdv) { create(:rdv, id: 55) }

  describe "#call" do
    before do
      allow(Rdv).to receive(:find_or_initialize_by)
        .with(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
        .and_return(rdv)
      allow(rdv).to receive(:save!)
      allow(rdv).to receive(:changed?)
    end

    it "retrieves the rdv if present" do
      expect(Rdv).to receive(:find_or_initialize_by)
        .with(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
      subject
    end

    it "updates the attributes" do
      subject
      expect(rdv.starts_at).to eq(starts_at)
      expect(rdv.duration_in_min).to eq(duration_in_min)
      expect(rdv.status).to eq(status)
      expect(rdv.applicant_ids).to eq(applicant_ids)
      expect(rdv.id).not_to eq(rdv_solidarites_rdv_id)
    end
  end
end
